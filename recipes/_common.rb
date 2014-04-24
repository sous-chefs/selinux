
case node[:platform_family]
when %r(debian|ubuntu)
  package 'selinux-utils'
when 'rhel'
  package 'libselinux-utils'
else
    # type code here
    raise "#{node[:platform_family]} not supported!"
end

directory '/etc/selinux' do
  owner 'root'
  mode '0755'
  action :create
end
