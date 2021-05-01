#
# Cookbook:: selinux
# Resource:: boolean
#
# Copyright:: 2016-2019, Chef Software, Inc.
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

property :boolean, String,
          required: true

property :value, [Integer, String, TrueClass, FalseClass],
          required: true

action :set do
  script "boolean_#{new_resource.boolean}" do
    interpreter 'bash'
    code "setsebool -P #{new_resource.boolean} #{selinux_bool_value}"
    not_if "getsebool #{new_resource.boolean} |egrep -q \" #{selinux_bool_value}\"$"
  end
end

action_class do
  def selinux_bool_value
    SELinuxServiceHelpers.selinux_bool(new_resource.value)
  end
end
