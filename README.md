# SELinux Cookbook

> [!IMPORTANT]
> This cookbook is deprecated. Chef Infra Client 18.0 and later include built-in
> `selinux_boolean`, `selinux_fcontext`, `selinux_install`, `selinux_login`,
> `selinux_module`, `selinux_permissive`, `selinux_port`, `selinux_state`, and
> `selinux_user` resources. New work should use those built-in Chef Infra Client
> resources directly.
>
> Open functional reports against this cookbook, including fcontext built-in
> override behavior, module reinstall behavior, module compilation behavior, and
> Amazon Linux 2023 package defaults, affect resource behavior that is now owned
> by Chef Infra Client. Please file follow-up fixes in
> [chef/chef](https://github.com/chef/chef) instead of extending this deprecated
> compatibility cookbook.

[![Cookbook Version](https://img.shields.io/cookbook/v/selnux.svg)](https://supermarket.chef.io/cookbooks/selinux)
[![CI State](https://github.com/sous-chefs/selinux/workflows/ci/badge.svg)](https://github.com/sous-chefs/selinux/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

## Description

The SELinux (Security Enhanced Linux) cookbook provided recipes and custom resources for manipulating SELinux policy enforcement state.

This cookbook is retained only for existing Chef Infra Client 15-17 users that cannot yet move to Chef Infra Client 18 or later. It should not be added to new cookbooks.

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

Chef Infra Client 18.0 and later provide the SELinux resources directly. Prefer the built-in resources on those releases.

## Platform

- RHEL 7+
- CentOS 7+
- Fedora
- Ubuntu
- Debian

## Resources

The following resources are provided:

- [selinux_boolean](documentation/selinux_boolean.md)
- [selinux_fcontext](documentation/selinux_fcontext.md)
- [selinux_install](documentation/selinux_install.md)
- [selinux_login](documentation/selinux_login.md)
- [selinux_module](documentation/selinux_module.md)
- [selinux_permissive](documentation/selinux_permissive.md)
- [selinux_port](documentation/selinux_port.md)
- [selinux_state](documentation/selinux_state.md)
- [selinux_user](documentation/selinux_user.md)

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
