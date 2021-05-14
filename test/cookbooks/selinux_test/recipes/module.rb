selinux_module 'create' do
  source 'test.te'
  force true
  action :create
end

selinux_module 'test' do
  action :remove
end
