#
# Cookbook Name:: selinux
# Resource:: fcontext
#
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

include Chef::Util::Selinux

def whyrun_supported?
  true
end

def need_update
  if !@new_resource.selinux_range.nil? && @current_resource.selinux_range != @new_resource.selinux_range then
    return true
  end
  if !@new_resource.selinux_user.nil? && @current_resource.selinux_user != @new_resource.selinux_user then
    return true
  end
  # Chef::Log.debug("Comparing new type: '#{@new_resource.selinux_type}', current type: '#{@current_resource.selinux_type}'")
  if !@new_resource.selinux_type.nil? && @current_resource.selinux_type != @new_resource.selinux_type then
    return true
  end
  false
end

action :add do
  if selinux_support? then
    if @new_resource.selinux_range.nil? and
       @new_resource.selinux_user.nil? and
       @new_resource.selinux_type.nil? then
      raise "selinux_fcontext with action :add must have at least one of range, user or type set!"
    end
    if need_update then
      args=""
      if !@new_resource.ftype.nil? then
        args += " -f #{@new_resource.ftype}"
      end
      if !@new_resource.selinux_range.nil? then
        args += " -r #{@new_resource.selinux_range}"
      end
      if !@new_resource.selinux_user.nil? then
        args += " -s #{@new_resource.selinux_user}"
      end
      if !@new_resource.selinux_type.nil? then
        args += " -t #{@new_resource.selinux_type}"
      end
      args += " #{@new_resource.path}"
      if !@current_resource.path.nil? then
        # Need to create the entry
        command = "/usr/sbin/semanage fcontext -a #{args}"
      else
        # Need to modify the existing entry
        command = "/usr/sbin/semanage fcontext -m #{args}"
      end
      # Chef::Log.debug("Command: '#{command}'")
      `#{command}`

      @new_resource.updated_by_last_action(true)
    end
  end

end

action :delete do
  if selinux_support? then
    if !@current_resource.path.nil? then
      # need to delete the existing entry
      args=""
      if !@new_resource.ftype.nil? then
        args += " -f #{@new_resource.ftype}"
      end
      args += " #{@new_resource.path}"
      command = "/usr/sbin/semanage fcontext -d #{args}"
      Chef::Log.info("Command: '#{command}'")
      `#{command}`
      @new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::SelinuxFcontext.new(@new_resource.name)
  @current_resource.path(nil) # nil indicates that the context doesn't exist yet
  @current_resource.ftype(nil)
  @current_resource.selinux_range(nil)
  @current_resource.selinux_user(nil)
  @current_resource.selinux_type(nil)

  if selinux_support? then
    # first, we need to make sure we need to make sure that the policycoreutils-python
    # package is installed. It contains the semanage utility
    # but we don't want that to happen if SELinux doesn't exist or if semanage already
    # exists.
    package "policycoreutils-python" do
      not_if{ ::File.exists?("/usr/sbin/semanage") }
    end

    # because the path itself can be a regular expression, we need to use
    # the non-regex version of grep
    val = nil
    `/usr/sbin/semanage fcontext -l`.each_line do |line|
      line.strip!
      path=line.slice!(/^[^ ]*/)
      context=line.slice!(/[^ ]*$/)
      tmp=line.strip
      case tmp
      when "all files"
        ftype = nil
      when "named pipe"
        ftype = "p"
      when "symbolic link"
        ftype = "l"
      when "block device"
        ftype = "b"
      when "socket"
        ftype = "s"
      when "character device"
        ftype = "c"
      when "directory"
        ftype = "d"
      when "regular file"
        ftype = "-"
      else
        ftype = nil
      end
      Chef::Log.debug("Path: '#{path}' Context: '#{context}', FType: '#{ftype}'")

      if path == @new_resource.path and ftype == @new_resource.ftype then
        context_parts = context.split(':')
        @current_resource.selinux_user(context_parts[0])
        @current_resource.selinux_type(context_parts[2])
        @current_resource.selinux_range(context_parts[3])
        @current_resource.path(@new_resource.path)
        @current_resource.ftype(@new_resource.ftype)
        break
      end
    end
  end

  @current_resource
end

# Should the new context be applied to existing files?
# Note: this only applies if the SELinux context has been changed.
# If the path is a pattern, then only the beginning of the pattern
# will be used, and the relabel will be done recursively. This may
# in rare cases relabel some additional files not included in the
# pattern.
# attribute :relabel, :kind_of => [TrueClass, FalseClass], :default => true
# Should the new context be applied to existing files?
# Note: this will be done non-idempotently even if the context in the
# database has not changed. Use this attribute only with action :nothing
# and notifications.
# Use case: use this if you installed a new file and aren't sure if it has
# the correct SELinux context.
# attribute :forcerelabel, :kind_of => [TrueClass, FalseClass], :default => false

