describe command('seinfo --portcon=29000') do
  its('stdout') { should match 'portcon tcp 29000 system_u:object_r:http_port_t:s0' }
  its('stdout') { should match 'portcon udp 29000 system_u:object_r:http_port_t:s0' }
end

describe command('seinfo --portcon=29001') do
  its('stdout') { should match 'portcon tcp 29001 system_u:object_r:ssh_port_t:s0' }
end
