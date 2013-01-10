# Cookbook Name:: selinux
# Recipe:: setroubleshoot
#
# Copyright 2012, North County Tech Center, LLC
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

[ "policycoreutils-python", "setroubleshoot-server", "setroubleshoot-plugins", "setools-console" ].each do |pkg|
   package pkg
end

selinuxmonitors = search(:users, "groups:selinuxmonitor").map do |usr| usr['email'] end

file "/var/lib/setroubleshoot/email_alert_recipients" do
   action :create
   owner "root"
   group "root"
   mode "0600"
   backup 0
   content selinuxmonitors.join("\n")
end

# The SEtroubleshoot driver require dbus, and that may not be running
service "messagebus" do
   action [ :enable, :start ]
end

