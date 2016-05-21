#
# Cookbook Name:: selinux_module_test
#        Recipe:: create
#
#

selinux_module 'create' do
  source 'test.te'
  force true
  action :create
end

# EOF
