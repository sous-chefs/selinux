Description
===========

Provides recipes for manipulating SELinux policy enforcement state.

Requirements
============

RHEL family distribution or other Linux system that uses SELinux.

## Platform:

Tested on RHEL 5.8, 6.3

Node Attributes
===============

* `node['selinux']['state']` - The SELinux policy enforcement state.
  The state to set  by default, to match the default SELinux state on
  RHEL. Can be "enforcing", "permissive", "disabled"

* `node['selinux']['booleans']` - A hash of SELinux boolean names and the
  values they should be set to. Values can be off, false, or 0 to disable;
  or on, true, or 1 to enable.

* `node['selinux']['needs_reboot']` - Either disabling a SELinux
  enforcing/permissive host or enabling a SELinux disabled host requires a
  reboot to take full effect. This attribute allows for a `knife search` to
  query for any such hosts.

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
      "recipe[selinux::permissive]",
    )

Testing
=======

### Unit testing

Invoke ChefSpec unit tests with `rspec`.

### Integration testing

The [example .kitchen.local.yml](.kitchen.local.yml.example) shows how to make use of the available test suites. Changing SELinux status requires a reboot in some cases. An example testing workflow:

```bash
# make a local kitchen config
cp .kitchen.local.yml.example .kitchen.local.yml

# set a filter if working on a subset of tests
filter=disabled

# run first pass verification
kitchen test $filter -c 4 -d never

# psuedo-knife search for nodes that need rebooted
kitchen exec $filter -c "grep -o 'needs_reboot\":[[:alpha:]]\+' /tmp/kitchen/chef_node.json || true"

# reboot them
reboot_me=$(kitchen exec $filter -c "grep -o 'needs_reboot\":[[:alpha:]]\+' /tmp/kitchen/chef_node.json || true" | grep true -B1 | paste - - | cut -f 5 -d ' ' | tr -d '.')

for i in $reboot_me; do kitchen exec $i -c 'sudo reboot || true' 2>/dev/null; done

# grab a coffee while nodes reboot

# reconverge rebooted nodes
kitchen converge $filter -c 4

# run second pass verification
kitchen verify $filter -c 4

# show no nodes need rebooted
kitchen exec $filter -c "grep -o 'needs_reboot\":[[:alpha:]]\+' /tmp/kitchen/chef_node.json || true"

# clean up
kitchen destroy $filter -c 4
```

Roadmap
=======

Add LWRP/Libraries for manipulating security contexts for files and
services managed by Chef.

License and Author
==================

- Author:: Sean OMeara (<someara@chef.io>)
- Author:: Joshua Timberman (<joshua@chef.io>)

Copyright:: 2011-2012, Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
