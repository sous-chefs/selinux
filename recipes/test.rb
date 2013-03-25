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

# test an existing context, at least in RedHat
selinux_fcontext "/var/run/xdmctl(/.*)?" do
  action :add
  selinux_range 's0'
  selinux_user  'system_u'
  selinux_type  'xdm_var_run_t'
end

# and a context that shouldn't exist - at least out of the box
selinux_fcontext "/invalid_test_directory" do
  action :add
  selinux_type  'xdm_var_run_t'
end

# Change the type of the just-created context
selinux_fcontext "/invalid_test_directory" do
  action :add
  selinux_type  'tmp_t'
end

# And test deleting the context we just created
selinux_fcontext "/invalid_test_directory" do
  action :delete
end

