default['selinux']['booleans'] = {}
default['selinux']['needs_reboot'] = nil
default['selinux']['state'] = 'enforcing'

case node['platform_family']
when 'debian'
  default['selinux']['packages'] = node['selinux']['state'] != 'disabled' ?
    %w(selinux-utils selinux-policy-default selinux-basics auditd) :
    %w(selinux-utils)
when %r(fedora|rhel)
  default['selinux']['packages'] = %w(libselinux-utils)
else
  raise "#{node['platform_family']} not supported!"
end
