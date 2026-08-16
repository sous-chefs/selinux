# frozen_string_literal: true

name 'selinux'

run_list 'selinux_test::install'

cookbook 'selinux', path: '.'
cookbook 'selinux_test', path: 'test/cookbooks/selinux_test'
cookbook 'apt', git: 'https://github.com/chef-cookbooks/apt.git', branch: 'main'

named_run_list :enforcing,
               'selinux_test::install',
               'selinux_test::enforcing',
               'selinux_test::debian_enforcing_prepare',
               'selinux_test::module_create',
               'selinux_test::module_remove',
               'selinux_test::boolean'
named_run_list :permissive,
               'selinux_test::install',
               'selinux::permissive',
               'selinux_test::module_create',
               'selinux_test::boolean'
named_run_list :disabled,
               'selinux_test::install',
               'selinux::disabled'
named_run_list :port,
               'selinux_test::install',
               'selinux::permissive',
               'selinux_test::port'
named_run_list :fcontext,
               'selinux_test::install',
               'selinux::permissive',
               'selinux_test::fcontext'
named_run_list :permissive_resource,
               'selinux_test::install',
               'selinux::permissive',
               'selinux_test::permissive_resource'
named_run_list :user_login_mapping,
               'selinux_test::install',
               'selinux::permissive',
               'selinux_test::user',
               'selinux_test::login'
