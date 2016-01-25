
case node['platform_family']
when %r(debian|ubuntu)
  include_recipe 'apt'
  if node['platform_version'].to_f <= 12
    %w(selinux-utils selinux-policy-default selinux-basics auditd).each { |pkg|
      package pkg
    }
  elsif
    %w(selinux selinux-utils selinux-policy-ubuntu selinux-basics auditd).each { |pkg|
      package pkg if node['selinux']['state'] == 'enabled'
    }
  end
  include_recipe 'selinux::debian'
when %r(fedora|rhel)
  if node['platform_version'].to_f >= 7.0
    include_recipe 'yum::dnf_yum_compat'
  end
  package 'libselinux-utils'
else
    # implement support for your platform here!
    raise "#{node['platform_family']} not supported!"
end

directory '/etc/selinux' do
  owner 'root'
  group 'root'
  mode '0755'
  action if node['selinux']['state'] == 'disabled' ? :nothing : :create
end
