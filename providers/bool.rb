#
# Author:: Matt Kynaston <matt@kynx.org>
# Cookbook Name:: selinux
# Provider:: selinux_bool
#
# Copyright:: 2012, Matt Kynaston <matt@kynx.org>
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
#

action :set do
  execute "set seboolean" do
    not_if "getsebool #{new_resource.name} | grep '--> #{new_resource.name}'"
    command "setsebool #{new_resource.name} #{new_resource.value}"
  end
end

