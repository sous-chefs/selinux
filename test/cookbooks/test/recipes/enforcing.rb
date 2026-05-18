# frozen_string_literal: true

if platform_family?('debian')
  # Ubuntu breaks kitchen SSH connections by default so need to load a module or two first
  selinux_state 'permissive' do
    automatic_reboot true
    action :permissive
  end
else
  selinux_state 'enforcing' do
    automatic_reboot true
    action :enforcing
  end
end
