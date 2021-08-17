#
# Cookbook:: selinux
# Resource:: fcontext
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

unified_mode true

property :file_spec, String,
          name_property: true,
          description: ''

property :secontext, String,
          description: ''

property :file_type, String,
          default: 'a',
          equal_to: %w(a f d c b s l p),
          description: ''

property :allow_disabled, [true, false],
          default: true

action :addormodify do
  run_action(:add)
  run_action(:modify)
end

# Run restorecon to fix label
# https://github.com/sous-chefs/selinux_policy/pull/72#issuecomment-338718721
action :relabel do
  spec = new_resource.file_spec
  escaped = Regexp.escape spec

  # find common path between regex and string
  common = if spec == escaped
             spec
           else
             index = spec.size.times { |i| break i if spec[i] != escaped[i] }
             ::File.dirname spec[0...index]
           end

  # if path is not absolute, ignore it and search everything
  common = '/' if common[0] != '/'

  execute 'selinux-fcontext-relabel' do
    command "find #{common.shellescape} -ignore_readdir_race -regextype posix-egrep -regex #{spec.shellescape} -prune -print0 2>/dev/null | xargs -0 restorecon -iRv"
    only_if { ::File.exist? common }
  end
end

# Create if doesn't exist, do not touch if fcontext is already registered
action :add do
  execute "selinux-fcontext-#{new_resource.secontext}-add" do
    command "semanage fcontext -a #{semanage_options(new_resource.file_type)} -t #{new_resource.secontext} '#{new_resource.file_spec}'"
    not_if fcontext_defined(new_resource.file_spec, new_resource.file_type)
    only_if { use_selinux(new_resource.allow_disabled) }
    notifies :relabel, new_resource, :immediately
  end
end

# Delete if exists
action :delete do
  execute "selinux-fcontext-#{new_resource.secontext}-delete" do
    command "semanage fcontext #{semanage_options(new_resource.file_type)} -d '#{new_resource.file_spec}'"
    only_if fcontext_defined(new_resource.file_spec, new_resource.file_type, new_resource.secontext)
    only_if { use_selinux(new_resource.allow_disabled) }
    notifies :relabel, new_resource, :immediately
  end
end

action :modify do
  execute "selinux-fcontext-#{new_resource.secontext}-modify" do
    command "semanage fcontext -m #{semanage_options(new_resource.file_type)} -t #{new_resource.secontext} '#{new_resource.file_spec}'"
    only_if fcontext_defined(new_resource.file_spec, new_resource.file_type)
    not_if  fcontext_defined(new_resource.file_spec, new_resource.file_type, new_resource.secontext)
    only_if { use_selinux(new_resource.allow_disabled) }
    notifies :relabel, new_resource, :immediately
  end
end
