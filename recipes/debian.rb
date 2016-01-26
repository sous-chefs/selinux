require 'tmpdir'

activate_persist = "#{Dir.tmpdir()}/selinux-activated"

unless node['selinux']['state'] == 'disabled'
  # first:  set true, activate
  # next:   no action (unless)
  # after:  no action (only_if)
  ruby_block 'selinux-activate' do
    block do
      unless ::File.exist?(activate_persist)
        activate_cmd = Mixlib::ShellOut.
          new("selinux-activate 2>&1 | tee #{activate_persist}")
        activate_cmd.run_command
        activate_cmd.error!
        node.default['selinux']['needs_reboot'] = true
      end
    end
    Chef::Log.warn "#{node['hostname']} must reboot to fully enable SELinux!"
    only_if "check-selinux-installation | grep -qx 'SELinux is not enabled.'"
  end
end

desired_action =
node['selinux']['state'] == 'disabled' ?
  [ :disable, :stop ] :
  [ :enable, :start ]

service 'selinux-basics' do
  status_command 'test -x /sys/fs/selinux'
  supports :restart => true
  action %w(node['selinix']['needs_reboot']) ? :nothing : desired_action
end
