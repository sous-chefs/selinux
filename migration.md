# Migration Guide

## Migrating From Recipes

This release removes the legacy `selinux::enforcing`, `selinux::permissive`, and `selinux::disabled` recipes. Use the `selinux_install` and `selinux_state` custom resources directly.

### Enforcing

```ruby
selinux_install 'selinux'

selinux_state 'enforcing' do
  automatic_reboot true
  action :enforcing
end
```

### Permissive

```ruby
selinux_install 'selinux'

selinux_state 'permissive' do
  automatic_reboot true
  action :permissive
end
```

### Disabled

```ruby
selinux_install 'selinux'

selinux_state 'disabled' do
  automatic_reboot true
  action :disabled
end
```

## Test Cookbook Examples

The cookbook's integration examples now live under `test/cookbooks/test/recipes/`. These recipes show the supported resource-first usage for package installation, state management, booleans, file contexts, modules, ports, permissive contexts, users, and login mappings.
