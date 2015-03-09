name             "selinux"
maintainer       "Sam Kottler"
maintainer_email "shk@linux.com"
license          "Apache"
description      "Manages SELinux policy state via LWRP or recipes."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.9.0"

%w{redhat centos scientific oracle amazon ubuntu debian}.each do |os|
  supports os
end

recipe "selinux", "Use LWRP with state attribute to manage SELinux state."
recipe "selinux::enforcing", "Use :enforcing as the action for the selinux_state."
recipe "selinux::permissive", "Use :permissive as the action for the selinux_state."
recipe "selinux::disabled", "Use :disabled as the action for the selinux_state."

attribute "selinux/state",
  :display_name => "SELinux State",
  :description => "The SELinux policy enforcement state.",
  :choices => ["enforcing", "permissive", "disabled"],
  :recipes => ["selinux::default"],
  :type => "string",
  :default => "enforcing"
