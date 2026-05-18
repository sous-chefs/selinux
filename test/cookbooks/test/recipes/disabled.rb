# frozen_string_literal: true

selinux_state 'disabled' do
  automatic_reboot true
  action :disabled
end
