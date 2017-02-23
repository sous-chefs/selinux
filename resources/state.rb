#
# Cookbook Name:: selinux
# Resource:: default
#
# Copyright 2016, Chef Software, Inc.
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

action_class do
  def getenforce
    @getenforce = shell_out('getenforce')
    @getenforce.stdout.chomp.downcase
  end

  def render_selinux_template(status)
    template "#{status} selinux config" do
      path '/etc/selinux/config'
      source 'sysconfig/selinux.erb'
      cookbook 'selinux'
      variables(
        selinux: status,
        selinuxtype: 'targeted'
      )
    end
    log 'Enabling selinux requires a reboot and relabeling the file system. ' if getenforce == 'disabled' && status == 'enforcing'
    log 'Disabling selinux requires a reboot.' if getenforce == 'enabled' && status =='disabled'
    # should log message if current status is disabled and new status is enabled
  end
end

action :enforcing do
  render_selinux_template('enforcing')
end

action :disabled do
  render_selinux_template('disabled')
end

action :permissive do
  render_selinux_template('permissive')
end
