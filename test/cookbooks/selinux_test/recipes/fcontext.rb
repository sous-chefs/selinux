directory '/opt/selinux-test'

%w( foo bar baz ).each do |f|
  file "/opt/selinux-test/#{f}"
end

directory '/opt/selinux-test/quux'

# single file
selinux_fcontext '/opt/selinux-test/foo' do
  label 'httpd_sys_content_t'
end

# regex
selinux_fcontext '/opt/selinux-test/b.+' do
  label 'boot_t'
end

# file type
selinux_fcontext '/opt/selinux-test/.+' do
  label 'etc_t'
  file_type 'd'
end
