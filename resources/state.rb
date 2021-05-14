#
# Cookbook:: selinux
# Resource:: state
#
# Copyright:: 2016-2021, Chef Software, Inc.
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

unified_mode true

default_action :nothing

property :config_file, String,
          default: '/etc/selinux/config'

property :persistent, [true, false],
          default: true,
          description: 'Persist status update to the selinux configuration file'

property :policy, String,
          default: 'targeted',
          equal_to: %w(targeted strict),
          description: 'SELinux policy type'

deprecated_property_alias 'temporary', 'persistent', 'The temporary property was renamed persistent in the 4.0 release of this cookbook. Please update your cookbooks to use the new property name.'

action_class do
  def enforce_status
    shell_out!('getenforce').stdout.strip.downcase.to_sym
  end

  def render_selinux_template(action)
    template "#{action} selinux config" do
      path new_resource.config_file
      source 'sysconfig/selinux.erb'
      cookbook 'selinux'
      variables(
        selinux: action.to_s,
        selinuxtype: new_resource.policy
      )
    end

    Chef::Log.warn(
      'It is advised to set the configuration to permissive to relabel the filesystem prior to enabling. Changes from disabled require a reboot.'
    ) if enforce_status == :disabled && action == :enforcing

    Chef::Log.info('Changes from disabled require a reboot.') if enforce_status == :disabled && %i(enforcing permissive).include?(action)
    Chef::Log.info('Disabling selinux requires a reboot.') if enforce_status != :disabled && action == :disabled
  end
end

action :enforcing do
  execute 'selinux-enforcing' do
    command '/usr/sbin/setenforce 1'
  end unless enforce_status.eql?(:enforcing)

  render_selinux_template(action) if new_resource.persistent
end

action :disabled do
  raise 'A non-persistent change to the disabled SELinux status is not possible.' unless new_resource.persistent
  render_selinux_template(action)
end

action :permissive do
  execute 'selinux-permissive' do
    command '/usr/sbin/setenforce 0'
  end unless enforce_status.eql?(:permissive)

  render_selinux_template(action) if new_resource.persistent
end
