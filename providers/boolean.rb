# Cookbook Name:: selinux
# Provider:: boolean
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
# === Authors
#
# Alberto del Barrio alberto.delbarrio.albelda@gmail.com

action :set do
  if boolean_true?(new_resource.boolean) == false
    cmd = "setsebool -P #{new_resource.boolean} 1"
    execute cmd do
      Chef::Log.debug "selinux_booleans #{cmd}"
      Chef::Log.info  "setting #{new_resource.boolean} to 1"
    end
  end
  new_resource.updated_by_last_action(true)
end

action :unset do
  if boolean_true?(new_resource.boolean) 
    cmd = "setsebool -P #{new_resource.boolean} 0"
    execute cmd do
      Chef::Log.debug "selinux_booleans #{cmd}"
      Chef::Log.info  "setting #{new_resource.boolean} to 0"
    end
  end
  new_resource.updated_by_last_action(true)
end

def boolean_true?(boolean)
  cmdStr = "getsebool #{boolean}"
  cmd = Mixlib::ShellOut.new(cmdStr)
  cmd.environment['HOME'] = ENV.fetch('HOME', '/root')
  cmd.run_command
  Chef::Log.debug "selinux_boolean_set #{cmdStr}"
  Chef::Log.debug "selinux_boolean_set #{cmd.stdout}"
  begin
      out = cmd.stdout.split()[2]
      if out.eql? "on" 
          true
      else
          false
      end
  end
end

