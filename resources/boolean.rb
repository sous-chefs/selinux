#
# Cookbook Name:: selinux
# Resource:: boolean
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

actions :set
default_action :set

# The bool_name attribute is the name of the SELinux boolean, as returned by
# getsebool. There will also be a file in /selinux/booleans by the same name
attribute :bool_name, :kind_of => String, :name_attribute => true, :required => true
attribute :value, :kind_of => [TrueClass, FalseClass], :required => true

def initialize(*args)
  super
  @action = :set
end

