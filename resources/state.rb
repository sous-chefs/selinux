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

include SELinux::Cookbook::StateHelpers

default_action :nothing

property :config_file, String,
          default: '/etc/selinux/config'

property :persistent, [true, false],
          default: true,
          description: 'Persist status update to the selinux configuration file'

property :policy, String,
          default: lazy { default_policy_platform },
          equal_to: %w(default minimum mls src strict targeted),
          description: 'SELinux policy type'

property :automatic_reboot, [true, false, Symbol],
          default: false,
          description: 'Perform an automatic node reboot if required for state change'

deprecated_property_alias 'temporary', 'persistent', 'The temporary property was renamed persistent in the 4.0 release of this cookbook. Please update your cookbooks to use the new property name.'

action_class do
  def enforce_status
    shell_out!('getenforce').stdout.strip.downcase.to_sym
  end

  def render_selinux_template(action)
    Chef::Log.warn(
      'It is advised to set the configuration first to permissive to relabel the filesystem prior to enforcing.'
    ) if enforce_status == :disabled && action == :enforcing

    unless new_resource.automatic_reboot
      Chef::Log.warn('Changes from disabled require a reboot.') if enforce_status == :disabled && %i(enforcing permissive).include?(action)
      Chef::Log.warn('Disabling selinux requires a reboot.') if enforce_status != :disabled && action == :disabled
    end

    template "#{action} selinux config" do
      path new_resource.config_file
      source 'selinux.erb'
      cookbook 'selinux'
      variables(
        selinux: action.to_s,
        selinuxtype: new_resource.policy
      )
    end

    # Return reboot required status
    (enforce_status == :disabled && %i(enforcing permissive).include?(action)) || (enforce_status != :disabled && action == :disabled)
  end

  def node_selinux_restart
    outer_action = action
    if new_resource.automatic_reboot
      reboot 'selinux_state_change' do
        delay_mins 1
        reason "SELinux state change to #{outer_action} from #{enforce_status}"

        action new_resource.automatic_reboot.is_a?(Symbol) ? new_resource.automatic_reboot : :reboot_now
      end
    else
      Chef::Log.warn("SELinux state change to #{action} requires a manual reboot as SELinux is currently #{enforce_status} and automatic reboots are disabled.")
    end
  end
end

action :enforcing do
  execute 'selinux-enforcing' do
    command '/usr/sbin/setenforce 1'
  end unless %i(enforcing disabled).include?(enforce_status)

  execute 'selinux-activate' do
    command '/usr/sbin/selinux-activate'
  end if platform_family?('debian') && enforce_status == :disabled

  reboot_required = render_selinux_template(action) if new_resource.persistent
  node_selinux_restart if reboot_required
end

action :permissive do
  execute 'selinux-permissive' do
    command '/usr/sbin/setenforce 0'
  end unless %i(permissive disabled).include?(enforce_status)

  execute 'selinux-activate' do
    command '/usr/sbin/selinux-activate'
  end if platform_family?('debian') && enforce_status == :disabled

  reboot_required = render_selinux_template(action) if new_resource.persistent
  node_selinux_restart if reboot_required
end

action :disabled do
  raise 'A non-persistent change to the disabled SELinux status is not possible.' unless new_resource.persistent

  reboot_required = render_selinux_template(action)
  node_selinux_restart if reboot_required
end
