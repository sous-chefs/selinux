# frozen_string_literal: true

selinux_state 'permissive' do
  automatic_reboot true
  action :permissive
end
