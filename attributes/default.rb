# possible values are enforcing, permissive and disabled
default['selinux']['state'] = 'enforcing'
# possible values are targeted and strict. Currently, strict is not
# supported and may or may not work
default['selinux']['type'] = "targeted"
default['selinux']['booleans'] = {}
