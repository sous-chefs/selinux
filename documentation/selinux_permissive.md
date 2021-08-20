[Back to resource list](../README.md#resources)

# selinux_permissive

Allows some types to misbehave without stopping them. Not as good as specific policies, but better than disabling SELinux entirely.

## Actions

| Action    | Description                                        |
| --------- | -------------------------------------------------- |
| `:add`    | *(Default)* Adds a permissive, unless already set. |
| `:delete` | Removes a permissive, if set.                      |

## Properties

| Name      | Type   | Default       | Description                                 |
| --------- | ------ | ------------- | ------------------------------------------- |
| `context` | String | Resource name | Name of the context to disable SELinux for. |

## Examples

```ruby
# Disable enforcement on Apache
selinux_permissive 'httpd_t' do
  notifies :restart, 'service[httpd]'
end
```
