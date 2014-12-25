#
# Cookbook Name:: selinux
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
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
    "fcontext -a -f 'regular file' -t #{type} '#{fc}'"
  else
    "fcontext -a -f 'all files' -t #{type} '#{fc}'"
  end
end

if fcontexts.length > 0 then
  importdata = fcontexts.join("\n")

  script "Add fcontexts" do
    interpreter "bash"
    code "echo \"#{importdata}\" | semanage -i -"
  end
end

