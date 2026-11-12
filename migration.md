# Moving from the SELinux cookbook to built-in resources

Use Chef Infra Client 18.1 or later for the complete replacement API. Most of
the resources arrived in 18.0; login and SELinux-user management arrived in
18.1. Keep the compatibility cookbook pinned until every managed client has the
resources that its run list needs.

## Resource mapping

The public resource names stay the same after removing the cookbook dependency.
Review the built-in documentation for the client version you deploy.

| Cookbook resource | Built-in resource | First client version |
| --- | --- | --- |
| `selinux_boolean` | [selinux_boolean](https://docs.chef.io/resources/selinux_boolean/) | 18.0 |
| `selinux_fcontext` | [selinux_fcontext](https://docs.chef.io/resources/selinux_fcontext/) | 18.0 |
| `selinux_install` | [selinux_install](https://docs.chef.io/resources/selinux_install/) | 18.0 |
| `selinux_login` | [selinux_login](https://docs.chef.io/resources/selinux_login/) | 18.1 |
| `selinux_module` | [selinux_module](https://docs.chef.io/resources/selinux_module/) | 18.0 |
| `selinux_permissive` | [selinux_permissive](https://docs.chef.io/resources/selinux_permissive/) | 18.0 |
| `selinux_port` | [selinux_port](https://docs.chef.io/resources/selinux_port/) | 18.0 |
| `selinux_state` | [selinux_state](https://docs.chef.io/resources/selinux_state/) | 18.0 |
| `selinux_user` | [selinux_user](https://docs.chef.io/resources/selinux_user/) | 18.1 |

Remove `depends 'selinux'` from consuming cookbooks and remove the cookbook from
Policyfiles or Berksfiles only after upgrading the clients. Existing resource
blocks can then resolve to the built-in resources instead of this cookbook.
Retain the desired contexts, policies, ports, booleans and user mappings.

## Replacing recipe includes

Replace `recipe[selinux::enforcing]`, `recipe[selinux::permissive]` and
`recipe[selinux::disabled]` with a recipe in your own cookbook. The corresponding
built-in action is `:enforcing`, `:permissive` or `:disabled`:

```ruby
selinux_install 'selinux'

selinux_state 'enforcing' do
  automatic_reboot true
  action :enforcing
end
```

The legacy recipes set `automatic_reboot true`; the example preserves that
behaviour. Review the reboot policy before deploying it. Setting the property
to `false` leaves any required reboot for a maintenance window instead.

The cookbook does not need to remove SELinux packages, policy modules, mappings
or configuration when a client moves to the built-ins. Repository retirement
also does not change the state of any managed host.

## Existing reports

Functional fixes now belong in [chef/chef](https://github.com/chef/chef). Existing
reports remain available as historical context:

* [#119: built-in fcontext override](https://github.com/sous-chefs/selinux/issues/119).
* [#118: module reinstall behaviour](https://github.com/sous-chefs/selinux/issues/118).
* [#114: module compilation](https://github.com/sous-chefs/selinux/issues/114).

Existing cookbook releases and repository history will remain available for
clients that need time to upgrade. No repository or package deletion is part of
this retirement.
