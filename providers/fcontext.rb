#
# Cookbook Name:: selinux
# Provider:: fcontext
#
# Copyright 2015, Krzysztof Szarek
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

use_inline_resources

action :create do
  path = new_resource.path
  fcontext = new_resource.fcontext

  check = Mixlib::ShellOut.new("ls -dZ #{path} | grep #{fcontext}")
  check.run_command

  if check.error?
    Chef::Log.info("Change fcontext for #{path} to #{fcontext}")

    semenage = Mixlib::ShellOut.new("semanage fcontext -a -t #{fcontext} '#{path}(/.*)?'")
    semenage.run_command
    semenage.error!

    restorecon = Mixlib::ShellOut.new("restorecon -R #{path}")
    restorecon.run_command
    restorecon.error!
    
    # notify chef about changes
    new_resource.updated_by_last_action(true)
  end
end
