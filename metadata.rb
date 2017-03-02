name             'selinux'
maintainer       'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license          'Apache'
description      'Manages SELinux policy state'
version          '1.0.2'

%w(redhat centos scientific oracle amazon fedora).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/selinux'
issues_url 'https://github.com/chef-cookbooks/selinux/issues'
chef_version '>= 12.5'
