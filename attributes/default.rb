# setting SELinux via an attribute of
# 'enforcing', 'permissive', 'disabled'
# IIRC Default is enforcing

default['selinux']['state'] = 'enforcing'
