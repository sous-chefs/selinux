directory '/opt/selinux-test'

%w( foo bar baz ).each do |f|
  file "/opt/selinux-test/#{f}"
end

directory '/opt/selinux-test/quux'

# single file
selinux_fcontext '/opt/selinux-test/foo' do
  secontext 'httpd_sys_content_t'
end

# regex
selinux_fcontext '/opt/selinux-test/b.+' do
  secontext 'boot_t'
end

# file type
selinux_fcontext '/opt/selinux-test/.+' do
  secontext 'etc_t'
  file_type 'd'
end

# testing override of built-in context, using '/home/[^/]+/\.ssh(/.*)?'
# Use converge counter so we only do the fcontext manipulation in first round. Otherwise
# the "enforce_idempotency" will cause converge to fail.

node.run_state['chef_converge_counter'] = shellout('cat /tmp/chef_converge_counter').stdout.to_i
node.run_state['chef_converge_counter'] += 1
file '/tmp/chef_converge_counter' do
  content lazy { node.run_state['chef_converge_counter'].to_s }
  mode '0644'
  only_if { node.run_state['chef_converge_counter'] == 1 }
end

execute 'Check built-in fcontext' do
  command 'matchpathcon /home/user1/.ssh | grep ssh_home_t'
  only_if { node.run_state['chef_converge_counter'] == 1 }
end

# override with 'shadow_t'
selinux_fcontext '/home/[^/]+/\.ssh(/.*)?' do
  secontext 'shadow_t'
  action :add
  only_if { node.run_state['chef_converge_counter'] == 1 }
end

execute 'Check fcontext override' do
  command 'matchpathcon /home/user1/.ssh | grep shadow_t'
  only_if { node.run_state['chef_converge_counter'] == 1 }
end

# remove the override
selinux_fcontext '/home/[^/]+/\.ssh(/.*)?' do
  action :delete
  only_if { node.run_state['chef_converge_counter'] == 1 }
end


