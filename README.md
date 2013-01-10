Description
===========

Provides recipes for manipulating selinux policy enforcement

Requirements
============

RHEL family distribution or other Linux system that uses SELinux.

## Platform:

Tested on RHEL 5.6, 6.0 and 6.1.

Usage
=====

SELinux is enforcing by default on RHEL family distributions, however the use of SELinux has complicated considerations when using configuration management. Although not recommended from a security perspective, often, users want to set SELinux to permissive mode, or disable completely.

To ensure that SELinux is in the appropriate mode:
- Set the attribute node['selinux']['mode'] to the appropriate mode. Allowed are enforcing, permissive and disabled. The default is enforcing.
- Set the attribute node['selinux']['type'] to the approriate type. Allowed are targeted and strict. Recommended is targeted, as the cookbook is not tested for strict type.

Note: SELinux does not allow disabling or enabling a running system; changing mode to or from disabled will take effect on the next reboot. Changing between permissive and enforcing will take effect immediately.

If the current mode is "disabled" the file system will be completely relabeled upon reboot.

For example in a `base` role used by all RHEL systems:

    name "base"
    description "Base role applied to all nodes."
    run_list(
      "recipe[selinux::enforcing]",
    )

To install and configure the setroubleshoot package:

SEtroubleshoot will parse the SELinux log file for access denials, and send an email to a specified user.

To install and configure SEtroubleshoot:

- Create a user. and add it to the group "selinuxmonitor". Make sure the user has an email address.
- Use the recipe "selinux::setroubleshoot". All users who are member of the selinuxmonitor group will receive emails upon SELinux violations.

For instance, add the following user using the user cookbook:
{
  "id"        : "sample",
  "comment"   : "Sample User",
  "groups"    : [ "selinuxmonitor" ],
  "email"     : "sample user@example.com"
}




Roadmap
=======

Add LWRP/Libraries for manipulating security contexts for files and services managed by Chef.

License and Author
==================

Author:: Sean OMeara (<someara@opscode.com>)
Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: Kevin Keane (<kkeane@4nettech.com>)

Copyright:: 2011, Opscode, Inc
Copyright:: 2013, North County Tech Center, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
