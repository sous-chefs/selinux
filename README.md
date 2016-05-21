Description
===========

Provides recipes for manipulating SELinux policy enforcement state, and provider
to manage `.te` files into running SELinux Modules.

Requirements
============

RHEL family distribution or other Linux system that uses SELinux.

## Platform:

Tested on Centos 6.7 and 7.2, Fedora 22 and 23.

Node Attributes
===============

* `node['selinux']['state']` - The SELinux policy enforcement state. The state to
  set  by default, to match the default SELinux state on RHEL. Can be "enforcing",
  "permissive", "disabled"

* `node['selinux']['booleans']` - A hash of SELinux boolean names and the values
  they should be set to. Values can be off, false, or 0 to disable; or on, true,
  or 1 to enable.

Resources/Providers
===================

## `selinux_module`

This provider is intended to be part of the SELinux analysis workflow using tools
like `audit2allow`.

``` ruby
selinux_module 'WebSVN Service' do
  source 'websvn.te'
  action :create
end
```

Provider attributes:
- Actions: `create` or `remove`;
- `source`: SELinux `.te` file, to be parsed, compiled and deployed as module. If
  simple basename informed, the provider will first look into
  `files/default/selinux` directory;
- `base_dir`: Base directory to create and manage SELinux files, by default is
  `/etc/selinux/local`;
- `force`: Boolean. Inidicates if provider should re-install the same version of
  SELinux module already installed, in case the source `.te` file changes;

And then to remove a given module, use:

``` ruby
selinux_module 'websvn' do
  action :remove
end
```

## selinux\_state

The `selinux_state` LWRP is used to manage the SELinux state on the system. It
does this by using the `setenforce` command and rendering the
`/etc/selinux/config` file from a template.

### Actions

* `:nothing`: default action, does nothing
* `:enforcing`: Sets SELinux to enforcing.
* `:disabled`: Sets SELinux to disabled.
* `:permissive`: Sets SELinux to permissive.

### Attributes

The LWRP has no user-settable resource attributes.

### Examples

#### Managing State

Simply set SELinux to enforcing or permissive:

``` ruby
selinux_state "SELinux Enforcing" do
  action :enforcing
end

selinux_state "SELinux Permissive" do
  action :permissive
end
```

The action here is based on the value of the `node['selinux']['state']` attribute,
which we convert to lower-case and make a symbol to pass to the action.

``` ruby
selinux_state "SELinux #{node['selinux']['state'].capitalize}" do
  action node['selinux']['state'].downcase.to_sym
end
```

#### Managing `.te` Files

1. Add `selinux` to your `metadata.rb`, as for instance: `depends 'selinux', '>= 0.10.0'`;
2. Run your SELinux workflow, and add `.te` files on your cookbook files,
   preferably under `files/default/selinux` directory;
3. Write recipes using `selinux` provider;

##### SELinux `audit2allow` Workflow

This provider was written with the intention of matching the worflow of
`audit2allow` (provided by package `policycoreutils`), which basically will be:

1. Install the software you intent to use, add configuration users and such infra-structure;
2. Test application and inspect `/var/log/audit/audit.log` log-file with a command
   like this basic example: `grep AVC /var/log/audit/audit.log |audit2allow -M my_application`;
3. Save `my_application.te` SELinux module source, copy into your cookbook under
   `files/default/selinux/my_application.te`;
4. Make use of `selinux` provider on a recipe, after adding it as a dependency;

``` ruby
selinux_module 'MyApplication SELinux Module' do
  source 'my_application.te'
  action :create
end
```

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

By default, this cookbook will have SELinux enforcing by default, as the default
recipe uses the `node['selinux']['state']` attribute, which is "enforcing." This
is in line with the policy of enforcing by default on RHEL family distributions.

This has complicated considerations when changing the default configuration of
their systems, whether it is with automated configuration management or manually.
Often, third party help forums and support sites recommend setting SELinux to
"permissive." This cookbook can help with that, in two ways.

You can simply set the attribute in a role applied to the node:

``` ruby
name "base"
description "Base role applied to all nodes."
default_attributes(
  "selinux" => {
    "state" => "permissive"
  }
)
```

Or, you can apply the recipe to the run list (e.g., in a role):

``` ruby
name "base"
description "Base role applied to all nodes."
run_list(
  "recipe[selinux::permissive]",
)
```

Roadmap
=======

Add LWRP/Libraries for manipulating security contexts for files and services
managed by Chef.

Testing
=======

The following test suites are intent to run from the cookbook root folder, a
example boilerplate step would be:

```
$ git clone https://github.com/skottler/selinux.git
$ cd selinux
```

And then:
- **ChefSpec**: `$ chef exec rspec --format d --backtrace --fail-fast spec/*`;
- **KitchenCI**: `$ kitchen test`;

License and Author
==================

- Author:: Sean OMeara (<someara@chef.io>)
- Author:: Joshua Timberman (<joshua@chef.io>)

Copyright:: 2011-2012, Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
