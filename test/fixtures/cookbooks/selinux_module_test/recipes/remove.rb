#
# Cookbook Name:: selinux_module_test
#        Recipe:: remove
#
#

selinux_module 'remove' do
  source 'test.te'
  force true
  action :remove
end

# EOF
