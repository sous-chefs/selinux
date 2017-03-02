default_action :install

action :install do
  case node['platform_family']
  when 'debian'
    package 'selinux-basics'
  when 'ubuntu'
    package 'selinux-basics'
    package 'selinux-policy-default'
    package 'auditd'
  when 'rhel', 'fedora'
    package 'policycoreutils'
    package 'selinux-policy'
    package 'selinux-policy-targeted'
    package 'libselinux-utils'
    package 'mcstrans'
  else
    # implement support for your platform here!
    raise "#{node['platform_family']} not supported!"
  end

  directory '/etc/selinux' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end
