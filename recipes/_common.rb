case node['platform_family']
when 'debian'
  include_recipe 'apt'
when %r(fedora|rhel)
  include_recipe 'yum::dnf_yum_compat'
end

node['selinux']['packages'].each { |pkg|
  package pkg
}

include_recipe 'selinux::debian' if platform_family?('debian')
