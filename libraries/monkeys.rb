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

def monkey_into(theClass,theMethod,recursive)
  Chef::Log.debug("#{theClass.name}.#{theMethod.to_s}: monkey-patching")
  theClass.class_eval do
    
    Chef::Log.debug("#{theClass.name}.#{theMethod.to_s}: inside monkey")
    original_method = instance_method(theMethod)
    Chef::Log.debug("#{theClass.name}.#{theMethod.to_s}: saved method")

    define_method(theMethod) do
      # do all the things the original action should be doing
      original_method.bind(self).call

      # has anything changed? The updated_by_last_action flag may not yet have been set,
      # so we may need to instead rely on whether or not there were any converge actions
      was_changed = ((@new_resource.updated_by_last_action?) or (not converge_actions.empty?))

      # if any changes were made, make sure that the SELinux context
      # is set correctly.
      if was_changed and selinux_support? then
        command = "/sbin/restorecon #{recursive ? "-r" : "" } #{@new_resource.path}"
        `#{command}`
      end
    end
  end
end

# We need to monkey patch into a number of different resources that all have the
# potential to corrupt the SELinux context
monkey_into(Chef::Provider::File,:action_create,false)
# The current implementation of action_create_if_missing simply calls
# action_create, which causes the monkey-patched version to be called twice.
# This does no harm, and is preferable to the monkey-patch breaking if the
# underlying implementation is changed later.
monkey_into(Chef::Provider::File,:action_create_if_missing,false)

monkey_into(Chef::Provider::Template,:action_create,false)
monkey_into(Chef::Provider::RemoteFile,:action_create,false)
monkey_into(Chef::Provider::CookbookFile,:action_create,false)
monkey_into(Chef::Provider::Link,:action_create,false)
monkey_into(Chef::Provider::Directory,:action_create,true)
monkey_into(Chef::Provider::RemoteDirectory,:action_create,true)
monkey_into(Chef::Provider::RemoteDirectory,:action_create_if_missing,true)

