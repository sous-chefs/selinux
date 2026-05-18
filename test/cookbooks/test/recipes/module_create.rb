selinux_module 'test_create' do
  cookbook 'test'
  source 'test.te'
  module_name 'test'

  action :create
end
