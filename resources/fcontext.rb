#
# Cookbook Name:: selinux
# Resource:: fcontext
#
# Copyright 2013, North County Tech Center, LLC
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

actions :add, :delete, :import
default_action :add

# sets a file context in selinux' database, i.e., this is the equivalent
# of the semanage -fcontext command.

# The path that the SELinux context should be applied to
# For the :import action, the location of the import file in the local file system
attribute :path, :kind_of => String, :name_attribute => true, :required => true
# The file type that the context will apply to -
# (d) directories,
# (-) regular files, or
# (c) character device
# (b) block device
# (s) socket
# (l) symbolic link
# (p) named pipe
# (nil) everything?
attribute :ftype, :regex => /^[cbslpd\-]$/
# The SELinux MLS/MCS range
attribute :selinux_range, :kind_of => String
# The SELinux user - this is separate from the Linux user!
attribute :selinux_user, :kind_of => String
# The SELinux type. Required when the action is :add
attribute :selinux_type, :kind_of => String

def initialize(*args)
  super
  @action = :add
end

