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

# make sure the required utilities are installed
# Note that this will only take effect during the execute phase.
package "libselinux-utils"

# find out the desired SELinux mode and type
selinuxmode=node["selinux"]["mode"]
selinuxtype=node["selinux"]["type"]

case selinuxmode
when "disabled" then
when "permissive" then
when "enforcing" then
else
  raise "The attribute node['selinux']['mode'] must be one of disabled, permissive or enforcing. It is #{selinuxmode}"
end
case selinuxtype
when "targeted" then
when "strict" then
else
  raise "The attribute node['selinux']['type'] must be one of targeted or strict. It is #{selinuxtype}"
end

# find out the actually active mode. Because this runs during the compile phase,
# getenforce may not yet be installed.
if File.exists?("/usr/sbin/getenforce") then
  # we have to use downcase and strip to make sure we don't run into upper-case issues
  # and trailing newlines/whitespace don't confuse comparisons further down.
  currentmode=`/usr/sbin/getenforce`.downcase.strip
else
  # if the tools aren't installed yet, we can't call getenforce during the compile phase
  currentmode="unknown"
end



template "/etc/selinux/config" do
  source "sysconfig/selinux.erb"
  variables(
    :selinux => selinuxmode,
    :selinuxtype => selinuxtype
  )
end

# if we are switching to or from disabled mode, we must reboot.
# Also, if the system was in disabled mode before, the file system
# must be relabeled since no SELinux contexts were attached to files.
#
# To switch between permissive and enforcing, we can call
# setenforce
if selinuxmode!=currentmode then

  if selinuxmode=="disabled" then
    Log "You must reboot your Linux system for this change to take effect!"
  elsif currentmode=="disabled" then
    # creating the /.autorelabel file will cause SELinux to relabel all files
    # during the next reboot
    file "/.autorelabel"
    Log "You must reboot your Linux system for this change to take effect!"
  else
    # actually switch between permissive and enforcing
    execute "enable selinux enforcement - current: #{currentmode}. New: #{selinuxmode}" do
      command "setenforce #{selinuxmode}"
      action :run
    end
  end
end

