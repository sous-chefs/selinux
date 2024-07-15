include_controls 'common'

control 'fcontext' do
  title 'Verify that SELinux file contexts are set correctly'

  describe file('/opt/selinux-test/foo') do
    its('selinux_label') { should match 'httpd_sys_content_t' }
  end

  describe file('/opt/selinux-test/bar') do
    its('selinux_label') { should match 'boot_t' }
  end

  describe file('/opt/selinux-test/baz') do
    its('selinux_label') { should match 'boot_t' }
  end

  describe file('/opt/selinux-test/quux') do
    its('selinux_label') { should match 'etc_t' }
  end
end

control 'fcontext override' do
  title 'Verify that built-in SELinux file contexts override works correctly'

  describe command('matchpathcon /home/user1/.ssh') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /ssh_home_t/ }
  end
end
