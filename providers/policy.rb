#
# Author:: Matt Kynaston <matt@kynx.org>
# Cookbook Name:: selinux
# Provider:: selinux_policy
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

action :install do
  cookbook = new_resource.cookbook_name.to_s
  dir = "/usr/share/selinux/packages/#{cookbook}"
  te_file =  "#{dir}/#{new_resource.name}.te"
  mod_file = "#{dir}/#{new_resource.name}.mod"
  pp_file = "#{dir}/#{new_resource.name}.pp"
  directory dir do
    mode "0755"
    owner "root"
    group "root"
    action :create
  end
  f = cookbook_file te_file do
    cookbook cookbook
    source "#{new_resource.name}.te"
    mode "0755"
    owner "root"
    group "root"
    notifies :run, "execute[check_package_install]", :immediately
  end
  execute "check_package_install" do
    command "checkmodule -m -M -o #{mod_file} #{te_file} && semodule_package -o #{pp_file} -m #{mod_file} && semodule -i #{pp_file}"
    action :nothing
  end
  new_resource.updated_by_last_action(f.new_resource.updated_by_last_action?)
end

action :remove do
  cookbook = new_resource.cookbook_name.to_s
  dir = "/usr/share/selinux/packages/#{cookbook}"
  %w[ te mod pp ].each do |extn|
    file "#{dir}/#{new_resource.name}.#{extn}" do
      action :delete
    end
  end
  if ::Dir.entries(dir).empty?
      ::Dir.delete(dir)
  end
  e = execute "semanage -r #{new_resource.name}" do
    action :run
  end
  new_resource.updated_by_last_action(e.new_resource.updated_by_last_action?)
end