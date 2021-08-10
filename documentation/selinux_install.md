[Back to resource list](../README.md#resources)

# selinux_install

The `selinux_install` resource is used to encapsulate the set of selinux packages to install in order to manage selinux. It also ensures the directory `/etc/selinux` is created.

Introduced: v4.0.0

## Actions

- `:install`
- `:upgrade`
- `:remove`

## Properties

| Name       | Type          | Default                    | Description                 |
| ---------- | ------------- | -------------------------- | --------------------------- |
| `packages` | String, Array | `default_install_packages` | SELinux packages for system |

## Examples

### Default installation

```ruby
selinux_install '' do
  action :install
end
```

### Install with excluded packages

```ruby
selinux_install '' do
  packages_exclude %w(policycoreutils selinux-policy selinux-policy-targeted )
  action :install
end
```

### Uninstall

```ruby
selinux_install '' do
  action :remove
end
```
