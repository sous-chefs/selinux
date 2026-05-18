# Limitations

## Package Availability

SELinux tooling is provided by each supported distribution's native package repositories. The cookbook does not use a separate upstream vendor repository.

### APT (Debian/Ubuntu)

* Debian 12 and 13 provide `policycoreutils`, `selinux-basics`, `selinux-policy-default`, `selinux-policy-dev`, `auditd`, and `setools`.
* Ubuntu 22.04 and 24.04 provide the same package set from the Ubuntu repositories.
* Ubuntu 20.04 is past standard support and is no longer listed as a supported platform.

### DNF/YUM (RHEL family, Fedora, Amazon Linux)

* RHEL-family platforms use `policycoreutils`, `policycoreutils-python-utils`, `selinux-policy`, `selinux-policy-targeted`, `selinux-policy-devel`, `libselinux-utils`, and `setools-console`.
* Amazon Linux 2 still uses `policycoreutils-python`; Amazon Linux 2023 follows the current RHEL-family package shape.
* Fedora provides current SELinux policy utility packages through the standard Fedora repositories.

### Zypper (SUSE)

* openSUSE Leap 15 reached end of life on April 30, 2026 and is no longer listed as a supported platform.
* Leap 16 SELinux package coverage was not validated in this migration, so SUSE support is not advertised.

## Architecture Limitations

The cookbook installs distribution packages and has no architecture-specific download logic. Architecture support follows each distribution's package repositories.

## Source/Compiled Installation

The cookbook does not compile SELinux from source. The `selinux_module` resource can compile local policy modules using distribution-provided SELinux development packages.

## Known Issues

* Changing SELinux between disabled and enforcing/permissive can require a reboot.
* Debian and Ubuntu require additional activation steps before SELinux can enforce policy.
* Container-based Kitchen runs are suitable for package-install smoke coverage; full state transitions can require a VM or host environment with SELinux enabled.
