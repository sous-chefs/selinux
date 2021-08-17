%w(tcp udp).each do |prot|
  selinux_port '29000' do
    protocol prot
    secontext 'http_port_t'
  end
end

selinux_port '29001' do
  protocol 'tcp'
  secontext 'ssh_port_t'
end
