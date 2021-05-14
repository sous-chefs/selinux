selinux_boolean 'ssh_keysign' do
  value true
end

selinux_boolean 'httpd_enable_cgi' do
  value false
end

selinux_boolean 'ssh_use_tcpd' do
  value 'on'
end

selinux_boolean 'squid_connect_any' do
  value 'off'
end
