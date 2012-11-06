maintainer       "Opscode, Inc."
maintainer_email "someara@opscode.com"
license          "Apache"
description      "Installs/Configures selinux"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.5.3"

attribute "selinux/state"
  :display_name => "SELinux state"
  :description => "Choose from Enforcing, Permissive, Disabled"
  :default => "permissive"
