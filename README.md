# SELinux Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/selnux.svg)](https://supermarket.chef.io/cookbooks/selinux)
[![CI State](https://github.com/sous-chefs/selinux/workflows/ci/badge.svg)](https://github.com/sous-chefs/selinux/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

## Description

The SELinux (Security Enhanced Linux) cookbook provides recipes for manipulating SELinux policy enforcement state.

SELinux can have one of three settings:

`Enforcing`

- Watches all system access checks, stops all 'Denied access'
- Default mode on RHEL systems

`Permissive`

- Allows access but reports violations

`Disabled`

- Disables SELinux from the system but is only read at boot time. If you set this flag, you must reboot.

Disable SELinux only if you plan to not use it. Use `Permissive` mode if you just need to debug your system.

## Requirements

- Chef 15.3 or higher

## Platform:

- RHEL 7+

## Attributes

- `node['selinux']['state']` - The SELinux policy enforcement state. The state to set by default, to match the default SELinux state on RHEL. Can be "enforcing", "permissive", "disabled"
- `node['selinux']['booleans']` - A hash of SELinux boolean names and the values they should be set to. Values can be off, false, or 0 to disable; or on, true, or 1 to enable.
- `node['selinux']['install_mcstrans_package']` - Install mcstrans package, Default is `true`. If don't want to install mcstrans package, sets as a `false`

## Resources Overview

### selinux_state

The `selinux_state` resource is used to manage the SELinux state on the system. It does this by using the `setenforce` command and rendering the `/etc/selinux/config` file from a template.

### selinux_module

This provider is intended to be part of the SELinux analysis workflow using tools like `audit2allow`.

#### Actions

- `:create`: install the module;
- `:remove`: remove the module;

#### Options

- `source`: SELinux `.te` file, to be parsed, compiled and deployed as module. If simple basename informed, the provider will first look into `files/default/selinux` directory;
- `base_dir`: Base directory to create and manage SELinux files, by default is `/etc/selinux/local`;
- `force`: Boolean. Indicates if provider should re-install the same version of SELinux module already installed, in case the source `.te` file changes;

### selinux_state

The `selinux_state` resource is used to manage the SELinux state on the system. It does this by using the `setenforce` command and rendering the `/etc/selinux/config` file from a template.

#### Actions

- `:nothing`: default action, does nothing
- `:enforcing`: Sets SELinux to enforcing.
- `:disabled`: Sets SELinux to disabled.
- `:permissive`: Sets SELinux to permissive.

#### Properties

- `temporary` - true, false, default false. Allows the temporary change between permissive and enabled states which don't require a reboot.
- `selinuxtype` - targeted, mls, default targeted. Determines the policy that will be configured in the `/etc/selinux/config` file. The default value is `targeted` which enables selinux in a mode where only selected processes are protected. `mls` is multilevel security which enables selinux in a mode where all processes are protected.

### Examples

#### Managing SELinux State (`selinux_state`)

Simply set SELinux to enforcing or permissive:

```ruby
selinux_state "SELinux Enforcing" do
  action :enforcing
end

selinux_state "SELinux Permissive" do
  action :permissive
end
```

The action here is based on the value of the `node['selinux']['state']` attribute, which we convert to lower-case and make a symbol to pass to the action.

```ruby
selinux_state "SELinux #{node['selinux']['state'].capitalize}" do
  action node['selinux']['state'].downcase.to_sym
end
```

The action here is based on the value of the `node['selinux']['status']` attribute, which we convert to lower-case and make a symbol to pass to the action.

```ruby
selinux_state "SELinux #{node['selinux']['status'].capitalize}" do
  action node['selinux']['status'].downcase.to_sym
end
```

#### Managing SELinux Modules (`selinux_module`)

Consider the following steps to obtain a `.te` file, the rule description format employed on SELinux

1. Add `selinux` to your `metadata.rb`, as for instance: `depends 'selinux', '>= 0.10.0'`;
2. Run your SELinux workflow, and add `.te` files on your cookbook files, preferably under `files/default/selinux` directory;
3. Write recipes using `selinux_module` provider;

#### SELinux `audit2allow` Workflow

This provider was written with the intention of matching the workflow of `audit2allow` (provided by package `policycoreutils`), which basically will be:

1. Test application and inspect `/var/log/audit/audit.log` log-file with a command like this basic example: `grep AVC /var/log/audit/audit.log |audit2allow -M my_application`;
2. Save `my_application.te` SELinux module source, copy into your cookbook under `files/default/selinux/my_application.te`;
3. Make use of `selinux` provider on a recipe, after adding it as a dependency;

For example, add the following on the recipe level:

```ruby
selinux_module 'MyApplication SELinux Module' do
  source 'my_application.te'
  action :create
end
```

Module name is defined on `my_application.te` file contents, please note this input, is used during `:remove` action. For instance:

```ruby
selinux_module 'my_application' do
  action :remove
end
```

### selinux_install

The `selinux_install` resource is used to encapsulate the set of selinux packages to install in order to manage selinux. It also ensures the directory `/etc/selinux` is created.

## Recipes

All recipes will deprecate in the near future as they are just using the `selinux_state` resource.

### default

The default recipe will use the attribute `node['selinux']['status']` in the `selinux_state` resource's action. By default, this will be `:enforcing`.

### enforcing

This recipe will use `:enforcing` as the `selinux_state` action.

### permissive

This recipe will use `:permissive` as the `selinux_state` action.

### disabled

This recipe will use `:disabled` as the `selinux_state` action.

## Usage

By default, this cookbook will have SELinux enforcing by default, as the default recipe uses the `node['selinux']['status']` attribute, which is "enforcing." This is in line with the policy of enforcing by default on RHEL family distributions.

You can simply set the attribute in a role applied to the node:

```ruby
name "base"
description "Base role applied to all nodes."
default_attributes(
  "selinux" => {
    "status" => "permissive"
  }
)
```

Or, you can apply the recipe to the run list (e.g., in a role):

```ruby
name "base"
description "Base role applied to all nodes."
run_list(
  "recipe[selinux::permissive]",
)
```

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
