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

selinux_state "SELinux #{node['selinux']['state'].capitalize}" do
  action node['selinux']['state'].downcase.to_sym
end

node['selinux']['booleans'].each do |boolean, value|
  if ['on', 'true', '1'].include? value
    value = 'on'
  elsif ['off', 'false', '0'].include? value
    value = 'off'
  else
    Chef::Log.warn "Not a valid boolean value: #{value}"
    next
  end
  script "boolean_#{boolean}" do
    interpreter "bash"
    code "setsebool -P #{boolean} #{value}"
    not_if "getsebool #{boolean} |egrep -q \" #{value}\"$"
  end
end
