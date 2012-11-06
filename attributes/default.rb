# setting SELinux via an attribute of
# 'enabled', 'permissive', 'disabled'
# IIRC Default is permissive

default['selinux']['state'] = 'permissive'
