#
# Cookbook Name:: selinux
# Library:: monkeys.rb
#
# Copyright 2011, Opscode, Inc.
# Copyright 2013, North County Tech Center, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Originally written by Sean O'Meara
# Adapted by Kevin Keane

require 'chef/resource'
# require 'chef/config'
require 'chef/scan_access_control'
require 'chef/file_access_control'
require 'chef/file_access_control/unix'
require 'chef/log'
require 'chef/resource/directory'
require 'chef/provider'
require 'chef/provider/file'
require 'fileutils'

# utilities
module Chef::Util::Selinux

  # In Linux 3.0, the preferred mount point for the selinuxfs file
  # system is
  # /sys/fs/selinux
  # in Linux 2.6, it's usually /selinux
  # Add any other possible prefixes here. The first one will be used as
  # the default.
  # This is a fallback in case /proc/mounts for some reason does not
  # return the mountpoint
  @possible_prefixes = [ "/selinux", "/sys/fs/selinux" ]

  # access one of the SELinux "control" files in the /selinux directory
  #
  # Most of these files generally contain only the value 0 or 1 to indicate
  # true or false.
  #
  # The file name can be specified as absolute file including the
  # /selinux prefix, or as a relative file, which will be interpreted
  # with respect to the /selinux prefix.
  class ControlFile
    # we find selinux among the mounted file systems
    # Unfortunately, the mount command won't return it,
    # but /proc/mounts does contain it
    def find_selinux
       ::File.readlines("/proc/mounts").each { |line|
         l = line.split(" ")
         if l[2] == "selinuxfs" then
           return l[1]
         end
       }
       nil
    end

    def initialize(path)
      prefix = find_selinux

      if prefix == nil then
        prefix = @possible_prefixes[0]
        @possible_prefixes.each do |pref|
          if ::File.exists?(pref)
            prefix = pref
          end
        end
      end

      if path.start_with?(prefix)
        @filename = path
      elsif path.start_with?("/")
        # Just to be safe, if somebody specifies the path as
        # "/booleans/xxx" instead of "booleans/xxx"
        # we still handle it.
        @filename = "#{prefix}#{path}"
      else
        @filename = "#{prefix}/#{path}"
      end
    end

    # does the file exist? If not, either there is an
    # error in the file name, or SELinux is not supported
    # or is disabled.
    def exists?
      ::File.exists?(@filename)
    end

    # returns false if the file contains the value "0"
    # or true if the file contains the value "1".
    # If the file does not exist, or contains anything
    # else, returns false
    def value?(default = false)
      var = ""
      begin
        ::File.open(@filename, "r") { |f|
          var = f.gets
        }
        case var[0]
        when "1"
          true
        when "0"
          false
        else
          default
        end
      rescue
        Chef::Log.warn "SELinux is not active, or /selinux/#{path} does not exist"
        default
      end
    end

    def value=(val)
      begin
        ::File.open(@filename, "w") { |f|
          f.write(val ? "1" : "0")
        }
      rescue
        Log.warn "SELinux is not active, or /selinux/#{path} does not exist"
      end
    end

  end # class controlfile

  # VALUE Selinux_is_selinux_enabled(VALUE self)
  def selinux_support?
    # If SELinux is disabled, the /selinux directory
    # will be empty.
    # If SELinux is not supported on this platform,
    # the /selinux directory will not exist
    # If SELinux is enabled (enforcing or permissive),
    # the file /selinux/enforce will exist. It will
    # contain 0 for permissive, or 1 for enforcing

    ControlFile.new("enforce").exists?
  end

  # access to the context for one file or directory
  class SelinuxFileContext
    include Chef::Util::Selinux
    def initialize(path)
      @path = path
    end

    def type
      %x[/usr/bin/stat -c '%C' #{@path} | /usr/bin/secon -t]
    end

    def role
      %x[/usr/bin/stat -c '%C' #{@path} | /usr/bin/secon -r]
    end

    def user
      %x[/usr/bin/stat -c '%C' #{@path} | /usr/bin/secon -u]
    end

    # returns the user, role and type of the security context for the file
    # def contexts
      # return [nil,nil,nil] unless selinux_support?

      # value = %x[/usr/bin/stat -c '%C' #{@path}]
      # # the value will be either a string with two : separating the parts, or something
      # # that indicates an error. In that case, we return three empty strings
      # if value.count ":" == 2 then
        # value.split(":")
      # else
        # [nil,nil,nil]
      # end
    # end

  end

end # module Chef::Util::Selinux

# resources
class Chef
  class Resource
    include Chef::Util::Selinux
  end
end

class Chef
  class Provider
    include Chef::Util::Selinux
  end
end

class Chef
  class Resource
    class File < Chef::Resource
      def selinux_user(arg=nil)
        set_or_return( :selinux_user, arg, :kind_of => String)
      end
      def selinux_user=(arg=nil)
        set_or_return( :selinux_user, arg, :kind_of => String)
      end
      def selinux_role(arg=nil)
        set_or_return( :selinux_role, arg, :kind_of => String)
      end
      def selinux_role=(arg=nil)
        set_or_return( :selinux_role, arg, :kind_of => String)
      end
      def selinux_type(arg=nil)
        set_or_return( :selinux_type, arg, :kind_of => String)
      end
      def selinux_type=(arg=nil)
        set_or_return( :selinux_type, arg, :kind_of => String)
      end
    end
  end
end

# patch into the file access control class, since SELinux is
# really just another way of access control
class Chef
  class FileAccessControl
    module Unix
      include Chef::Util::Selinux

      def set_selinux!
        # TODO: implement
      end

      def set_selinux
        # TODO: implement
      end

      def set_all!
        set_owner!
        set_group!
        set_mode!
        set_selinux!
      end

      def set_all
        set_owner
        set_group
        set_mode
        set_selinux
      end

      def requires_changes?
        should_update_mode? || should_update_owner? || should_update_group? || should_update_selinux?
      end

      def describe_changes
        changes = []
        changes << "change mode from '#{mode_to_s(current_mode)}' to '#{mode_to_s(target_mode)}'" if should_update_mode?
        changes << "change owner from '#{current_resource.owner}' to '#{resource.owner}'" if should_update_owner?
        changes << "change group from '#{current_resource.group}' to '#{resource.group}'" if should_update_group?
        changes << "change selinux from '#{current_resource.selinux_contexts}' to '#{resource.selinux_context}'" if should_update_selinux?
        changes
      end

      def should_update_selinux?
        # TODO: implement
        false
      end

    end
  end
end

class Chef
  class ScanAccessControl
    include Chef::Util::Selinux

    def set_selinuxcontext
      context = SelinuxFileContext.new(@new_resource.path)
      # @current_resource.selinux_user(context.user)
      # @current_resource.selinux_role(context.role)
      # @current_resource.selinux_type(context.type)
    end

    def set_all!
      if ::File.exist?(new_resource.path)
        set_owner
        set_group
        set_mode
        set_selinuxcontext if selinux_support?
      else
        # leave the values as nil.
      end
    end
  end
end

