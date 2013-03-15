Description
===========

Provides recipes for manipulating SELinux policy enforcement state.

Requirements
============

RHEL family distribution or other Linux system that uses SELinux.

## Platform:

Tested on RHEL 5.8, 6.3, CentOS 6.4

WARNING
=======

If you disable or enable SELinux using this cookbook, you must reboot
the system for the change to take effect.

If you go from disabled mode to enforcing, booting may fail with a
kernel panic. This is due to missing SELinux context information on
some files.

- To recover, add the following to the kernel command line in grub:

selinux=0

- Boot into Linux as normal.

- Make sure the policycoreutils package is installed.

- Touch the file /.autorelabel

- Reboot

Enabling SELinux after it has been disabled requires relabeling the file
system. This cookbook will normally automatically take care of that.

Node Attributes
===============

* `node['selinux']['state']` - The SELinux policy enforcement state.
  The state to set  by default, to match the default SELinux state on
  RHEL. Can be "enforcing", "permissive", "disabled"

Resources/Providers
===================

## selinux\_state

The `selinux_state` LWRP is used to manage the SELinux state on the
system. It does this by using the `setenforce` command and rendering
the `/etc/selinux/config` file from a template.

### Actions

* `:nothing` - default action, does nothing
* `:enforcing` - Sets SELinux to enforcing.
* `:disabled` - Sets SELinux to disabled.
* `:permissive` - Sets SELinux to permissive.

### Attributes

The LWRP has no user-settable resource attributes.

### Examples

Simply set SELinux to enforcing or permissive:

    selinux_state "SELinux Enforcing" do
      action :enforcing
    end

    selinux_state "SELinux Permissive" do
      action :permissive
    end

The action here is based on the value of the
`node['selinux']['state']` attribute, which we convert to lower-case
and make a symbol to pass to the action.

    selinux_state "SELinux #{node['selinux']['state'].capitalize}" do
      action node['selinux']['state'].downcase.to_sym
    end

## selinux\_boolean

Sets the value for an SELinux boolean

### Actions

* `:nothing` - does nothing
* `:set` - Sets the value of the SELinux boolean

### Attributes

* `value` - the new value of the boolean. Either true or false

### Examples

Turn off the httpd_enable_homedirs boolean:

     selinux_boolean "httpd_enable_homedirs" do
       value false
     end

## selinux\_fcontext

Adds or removes an SELinux fcontext. The equivalent of the
semanage fcontext command.

Note: this context does not call restorecon, since there is no
good way to automatically figure out which files should
or should not be restored, and whether or not it should be
applied recursively.

To include restorecon, create an execute resource and notify

### Actions

* `:nothing` - does nothing
* `:add`     - Adds or modifies the fcontext
* `:delete`  - deletes an existing fcontext

### Attributes

* `path` - the path as it should be set in semanage.
           This is an semanage-style regular expression,
           rather than a Linux path name.
* `ftype` - the file type that this context should apply to.
            Valid are -dcbslp . These correspond to the
            letters from the mode field in the ls -l format.
            nil means, apply to all file types.
* `selinux_range` - the MLS/MCS security range. Only use this
                    on MLS/MCS systems. Corresponds to
                    the semanage fcontext -r argument
* `selinux_user` - The selinux user. Corresponds to
                   the semanage fcontext -s argument.
* `selinux_type` - The selinux type. Corresponds to
                   the semanage fcontext -t argument.

### Examples

Create or modify 

Creates an fcontext for all files under the /var/run/xdmctl directory.
Note: this example re-creates an fcontext that already is included in
the standard RedHat distribution.

      selinux_fcontext "/var/run/xdmctl(/.*)?" do
        action :add
        selinux_range 's0'
        selinux_user  'system_u'
        selinux_type  'xdm_var_run_t'
      end

Create a new fcontext that does not exist yet

      selinux_fcontext "/invalid_test_directory" do
        action :add
        selinux_type  'xdm_var_run_t'
      end

Change the type of the same context

      selinux_fcontext "/invalid_test_directory" do
        action :add
        selinux_type  'tmp_t'
      end

Delete the same context

      selinux_fcontext "/invalid_test_directory" do
        action :delete
      end

Create/modify an fcontext, and restorecon if needed

      execute "restorecon_sample" do
        action :nothing
        command "/sbin/restorecon -r /sample_directory"
      end

      selinux_fcontext "/sample_directory/(.*)?" do
        action :add
        selinux_type  'tmp_t'
      end


Recipes
=======

All the recipes now leverage the LWRP described above.

## default

The default recipe will use the attribute `node['selinux']['state']`
in the `selinux_state` LWRP's action. By default, this will be `:enforcing`.

## enforcing

This recipe will use `:enforcing` as the `selinux_state` action.

## permissive

This recipe will use `:permissive` as the `selinux_state` action.

## disabled

This recipe will use `:disabled` as the `selinux_state` action.

Usage
=====

By default, this cookbook will have SELinux enforcing by default, as
the default recipe uses the `node['selinux']['state']` attribute,
which is "enforcing." This is in line with the policy of enforcing by
default on RHEL family distributions.

This has complicated considerations when changing the default
configuration of their systems, whether it is with automated
configuration management or manually. Often, third party help forums
and support sites recommend setting SELinux to "permissive." This
cookbook can help with that, in two ways.

You can simply set the attribute in a role applied to the node:

    name "base"
    description "Base role applied to all nodes."
    default_attributes(
      "selinux" => {
        "state" => "permissive"
      }
    )

Or, you can apply the recipe to the run list (e.g., in a role):

    name "base"
    description "Base role applied to all nodes."
    run_list(
      "recipe[selinux::enforcing]",
    )

You can similarly set the SELinux type using an attribute

    name "base"
    description "Base role applied to all nodes."
    default_attributes(
      "selinux" => {
        "state" => "permissive",
        "type" => "targeted"
      }
    )

To install and configure the setroubleshoot package:

SEtroubleshoot will parse the SELinux log file for access denials, and send an email to a specified user.

To install and configure SEtroubleshoot:

- Create a user. and add it to the group "selinuxmonitor". Make sure the user has an email address.
- Use the recipe "selinux::setroubleshoot". All users who are member of the selinuxmonitor group will receive emails upon SELinux violations.

For instance, add the following user using the user cookbook:
{
  "id"        : "sample",
  "comment"   : "Sample User",
  "groups"    : [ "selinuxmonitor" ],
  "email"     : "sample user@example.com"
}




Roadmap
=======

Add LWRP/Libraries for manipulating security contexts for files and
services managed by Chef.

License and Author
==================

- Author:: Sean OMeara (<someara@opscode.com>)
- Author:: Joshua Timberman (<joshua@opscode.com>)

Copyright:: 2011-2012, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
