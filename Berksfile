source 'https://supermarket.chef.io'

metadata

cookbook 'apt'
cookbook 'yum', '~> 3.9.0'

group :integration do
  cookbook 'selinux_state_test', path: 'test/fixtures/cookbooks/selinux_state_test'
  cookbook 'export-node', path: 'test/fixtures/cookbooks/export-node'
end
