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

include Chef::Util::Selinux

def whyrun_supported?
  true
end

action :set do
  # For performance reasons, we check the boolean as set right now,
  # rather than the persistent value. It is theoretically possible
  # the boolean has been set non-persistently, although this would be
  # a fairly uncommon situation.
  # If this happens, the failure will be benign. If the boolean is
  # set to the wrong value, we'll simply set it again - no harmful
  # side effect, but not perfect idempotency.
  # If the boolean is set to the correct value already, this LWRP
  # will not touch it (and not add persistence). This is a problem
  # only after the system reboots - and will be automatically fixed
  # with the next chef run.

  if @current_resource.value != @new_resource.value then
    Chef::Log.info("Setting SELinux boolean #{@new_resource.name} to #{@new_resource.value ? "true" : "false"}")

    if selinux_support? then
      # first, we need to make sure we need to make sure that the policycoreutils-python
      # package is installed. It contains the semanage utility
      # but we don't want that to happen if SELinux doesn't exist or if semanage already
      # exists.
      package "policycoreutils" do
        not_if{ ::File.exists?("/usr/sbin/setsebool") }
      end
      `/usr/sbin/setsebool -P #{@new_resource.bool_name} #{@new_resource.value ? "1" : "0"}`
      @new_resource.updated_by_last_action(true)
    end
  end

end

def load_current_resource
  @current_resource = Chef::Resource::SelinuxBoolean.new(@new_resource.name)
  @current_resource.bool_name(@new_resource.bool_name)
  @current_resource.value(@new_resource.value)

  val = "invalid"
  if selinux_support? then
    @current_resource.value(ControlFile.new("booleans/#{@new_resource.bool_name}").value?)
  end

  Chef::Log.debug("Boolean #{@new_resource.bool_name} currently is #{val}, will be #{@new_resource.value ? "true" : "false" }. cur_res.value is #{@current_resource.value ? "true" : "false"}")

  @current_resource
end

