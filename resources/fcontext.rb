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

actions :add, :delete
default_action :add

# sets a file context in selinux' database, i.e., this is the equivalent
# of the semanage -fcontext command.

# The path that the SELinux context should be applied to
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
# Should the new context be applied to existing files?
# Note: this only applies if the SELinux context has been changed.
# If the path is a pattern, then only the beginning of the pattern
# will be used, and the relabel will be done recursively. This may
# in rare cases relabel some additional files not included in the
# pattern.
attribute :relabel, :kind_of => [TrueClass, FalseClass], :default => true
# Should the new context be applied to existing files?
# Note: this will be done non-idempotently even if the context in the
# database has not changed. Use this attribute only with action :nothing
# and notifications.
# Use case: use this if you installed a new file and aren't sure if it has
# the correct SELinux context.
attribute :forcerelabel, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(*args)
  super
  @action = :add
end

