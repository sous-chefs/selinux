#
# Cookbook:: selinux
# Resource:: module
#
# Copyright:: 2016-2021, Chef Software, Inc.
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

unified_mode true

property :cookbook, String,
          default: lazy { cookbook_name }

property :source, String,
          coerce: proc { |p| p.match?(%r{^selinux/}) ? p : "selinux/#{p}" }

property :base_dir, String,
          default: '/etc/selinux/local'

property :module_name, String,
          default: lazy { name }

action :create do
  directory new_resource.base_dir
  sefile_target_path = ::File.join(new_resource.base_dir, "#{new_resource.module_name}.te")
  sefile_pp_target_path = ::File.join(new_resource.base_dir, "#{new_resource.module_name}.pp")

  cookbook_file sefile_target_path do
    cookbook new_resource.cookbook
    source new_resource.source

    mode '0600'
    owner 'root'
    group 'root'

    action :create

    notifies :run, "execute[Compiling SELinux modules at '#{new_resource.base_dir}']", :immediately
  end

  execute "Compiling SELinux modules at '#{new_resource.base_dir}'" do
    cwd new_resource.base_dir
    command "make -C #{new_resource.base_dir} -f /usr/share/selinux/devel/Makefile"
    timeout 120
    user 'root'

    action :nothing

    notifies :run, "execute[Installing SELinux '.pp' module: '#{sefile_pp_target_path}']", :immediately
  end

  raise "Compilation must have failed, no 'pp' file found at: '#{sefile_pp_target_path}'" unless ::File.exist?(sefile_pp_target_path)

  execute "Installing SELinux '.pp' module: '#{sefile_pp_target_path}'" do
    command "semodule --install '#{sefile_pp_target_path}'"
    action :nothing
  end
end

action :remove do
  execute "Removing SELinux module: '#{new_resource.module_name}'" do
    command "semodule --remove='#{new_resource.module_name}'"
    action :run
  end if SELinux::Cookbook::ModuleHelpers.installed?(new_resource.module_name)
end
