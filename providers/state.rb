#
# Cookbook Name:: selinux
# Provider:: default
#
# Copyright 2011, Chef Software, Inc.
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

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

require 'tmpdir'

def whyrun_supported?
  true
end

activate_persist = "#{Dir.tmpdir()}/selinux-activated"

action :enforcing do
  unless ::File.exist?(activate_persist)
    unless (@current_resource.state == "enforcing")
      execute "selinux-enforcing" do
        not_if "getenforce | grep -qx 'Enforcing'"
        command "setenforce 1"
      end
      se_template = render_selinux_template("enforcing")
      new_resource.updated_by_last_action(true)
    end
  end
end

action :disabled do
  unless @current_resource.state == "disabled"
    execute "selinux-disabled" do
      not_if "selinuxenabled"
      command "setenforce 0"
    end
    node.default['selinux']['needs_reboot'] = true
    se_template = render_selinux_template("disabled")
    new_resource.updated_by_last_action(true)
  end
end

action :permissive do
  unless @current_resource.state == "permissive" || @current_resource.state == "disabled"
    execute "selinux-permissive" do
      not_if "getenforce | egrep -qx 'Permissive|Disabled'"
      command "setenforce 0"
    end
    se_template = render_selinux_template("permissive")
    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  @current_resource = Chef::Resource::SelinuxState.new(new_resource.name)
  @current_resource.state(`getenforce`.strip.downcase)
end

def render_selinux_template(state)
  # Debian hosts cannot execute restorecon against the template successfully
  # Use FileEdit as a workaround
  if platform_family?('debian')
    selinux_config_file = Chef::Util::FileEdit.new('/etc/selinux/config')
    ruby_block "write #{state} selinux config" do
      block do
        selinux_config_file.search_file_replace(/^SELINUX=(?!#{state}).*$/, "SELINUX=#{state}")
        selinux_config_file.write_file
      end
      not_if { ::File.open('/etc/selinux/config').read =~ /^SELINUX=#{state}$/ }
    end
  else
    template "#{state} selinux config" do
      path "/etc/selinux/config"
      source "sysconfig/selinux.erb"
      cookbook "selinux"
      if state == 'permissive'
        not_if "getenforce | grep -qx 'Disabled'"
      end
      variables(
        :selinux => state,
        :selinuxtype => "targeted"
      )
    end
  end
end
