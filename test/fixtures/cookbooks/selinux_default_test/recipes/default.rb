#
# Cookbook Name:: selinux_default_test
#        Recipe:: default
#
#

selinux 'create' do
  source 'test.te'
  force true
  action :create
end

selinux 'remove' do
  source 'test.te'
  force true
  action :remove
end

# EOF
