# selinux_state

[Back to resource list](../README.md#resources)

The `selinux_state` resource is used to manage the SELinux state on the system. It does this by using the `setenforce` command and rendering the `/etc/selinux/config` file from a template.

Introduced: v4.0.0

## Actions

| Action        | Description                                    |
| ------------- | ---------------------------------------------- |
| `:enforcing`  | *(Default)* Set the SELinux state to enforcing |
| `:permissive` | Set the state to permissive                    |
| `:disabled`   | Set the state to disabled                      |

> ⚠ Switching to or from `disabled` requires a reboot!

## Properties

| Name               | Type                | Default               | Description                                                        |
| ------------------ | ------------------- | --------------------- | ------------------------------------------------------------------ |
| `config_file`      | String              | `/etc/selinux/config` | Path to SELinux config file on disk                                |
| `persistent`       | true, false         | `true`                | Persist status update to the selinux configuration file            |
| `policy`           | String              | `targeted`            | SELinux policy type                                                |
| `automatic_reboot` | true, false, Symbol | `false`               | Whether to automatically reboot the node if needed to change state |

## Examples

```ruby
selinux_state 'enforcing' do
  action :enforcing
end
```

```ruby
selinux_state 'permissive' do
  action :permissive
end
```

```ruby
selinux_state 'disabled' do
  action :disabled
end
```

## Usage

### Managing SELinux State (`selinux_state`)

Set SELinux to enforcing or permissive:

```ruby
selinux_state 'SELinux Enforcing' do
  action :enforcing
end

selinux_state 'SELinux Permissive' do
  action :permissive
end
```
