package 'libselinux-utils'

directory '/etc/selinux' do
  owner 'root'
  mode '0644'
  action :create
end
