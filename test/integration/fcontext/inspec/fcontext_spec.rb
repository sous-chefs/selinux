describe command('stat -c "%n %C" /opt/selinux-test/*') do
  its('stdout') { should match 'foo unconfined_u:object_r:httpd_sys_content_t:s0' }
  its('stdout') { should match 'bar unconfined_u:object_r:boot_t:s0' }
  its('stdout') { should match 'baz unconfined_u:object_r:boot_t:s0' }
  its('stdout') { should match 'quux unconfined_u:object_r:httpd_tmp_t:s0' }
  its('stdout') { should_not match 'usr_t:s0' }
end
