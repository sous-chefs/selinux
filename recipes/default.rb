#
# Cookbook Name:: selinux
# Recipe:: default
#
# Copyright 2011, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'selinux::_common'

# semanage is not installed by default; we need to manually add it.
package "policycoreutils-python"

selinux_state "SELinux #{node['selinux']['state'].capitalize}" do
  action node['selinux']['state'].downcase.to_sym
end

node['selinux']['booleans'].each do |boolean, value|
  value = SELinuxServiceHelpers.selinux_bool(value)
  unless value.nil?
    script "boolean_#{boolean}" do
      interpreter "bash"
      code "setsebool -P #{boolean} #{value}"
      not_if "getsebool #{boolean} |egrep -q \" #{value}\"$"
    end
  end
end

############################################
# Add all the fcontexts that are not
# already in semanage. Since adding
# them individually is painfully slow,
# we collect a list of all required
# fcontexts first, and then import them
# all at once.

# Get the current fcontexts. Throw out header lines and the like
cmd = Mixlib::ShellOut.new("/usr/sbin/semanage fcontext -ln | egrep '.+:.+:.+:.+'")
cmd.run_command
cmdout = cmd.stdout.lines

current_fcontexts = Hash[cmdout.map{ |line|
  lineparts = line.split(' ')
  context = lineparts.first
  types = lineparts.last
  result = nil
  if not types.nil? then
    # note that the fields in between may contain spaces, and thus may have
    # been improperly split. We are only interested in the first and last
    # field, though.
    u,r,t,s = types.split(':')
    if not t.nil? then
      result = [context, t]
    end
  end
  result
}
]

fcontexts = node['selinux']['fcontexts'].select { |fc,type| current_fcontexts[fc] != type }.map do |fc,type|
  # special case handling: if the fc is /usr/lib(64)?/nagios/plugins/negate we need to use
  # 'regular file' instead of 'all files' because that context already exists with the wrong
  # value.
  if fc == "/usr/lib(64)?/nagios/plugins/negate" then
    # The syntax for the import command has changed in RH 7
    if node.platform_version.to_f >= 7.0 then
      "fcontext -a -f f -t #{type} '#{fc}'"
    else
      "fcontext -a -f 'regular file' -t #{type} '#{fc}'"
    end
  else
    # "fcontext -a -f 'all files' -t #{type} '#{fc}'"
    "fcontext -a -t #{type} '#{fc}'"
  end
end

############################################
# Process all ports, similar to the fcontexts
#
# SEManage returns ports as context - protocol - port list
# The port list is a comma/space-separate list that contains
# either individual ports, or ranges of ports.
# For instance:
# zebra_port_t                   udp      2600-2604, 2606

# TODO: properly process port ranges
cmd = Mixlib::ShellOut.new("/usr/sbin/semanage port -ln")
cmd.run_command
cmdout = cmd.stdout.lines

current_ports = Hash.new

cmdout.each{ |line|
  context,proto,portslist = line.split(' ',3)
  ports = portslist.split(',').map{ |p| p.strip() }
  current_ports[proto] = Hash.new if current_ports[proto].nil?
  ports.each do |port|
    current_ports[proto][port] = context
  end
}

# For each port that needs an selinux context configured,
# check if it is already included in currports - if not,
# add a line to be imported by semanage.
node['selinux']['ports'].each do |proto,protoports|
  ports = protoports.select{ |port,context|
      current_ports[proto][port.to_s] != context rescue true
    }.map{ |port,context|
      "port -a -t #{context} -p #{proto} #{port}"
    }
  fcontexts = fcontexts | ports
end

if fcontexts.length > 0 then
  importdata = fcontexts.join("\n")

  script "Import selinux configs" do
    interpreter "bash"
    code "echo \"#{importdata}\" | semanage -i -"
  end
end

