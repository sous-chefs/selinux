# SELinux cookbook retirement

## Confirmed scope

The owner authorised retirement on 12 November 2026. Preserve the existing
compatibility API, recipes, tags, releases, issues and published packages. Narrow
demonstrated package-default repairs are allowed; do not port this cookbook into
a new custom-resource implementation.
The replacement is Chef Infra Client's built-in SELinux resource API.

The compatibility cookbook still supports Chef 15.3 and later. The complete
built-in replacement requires 18.1: `selinux_login` and `selinux_user` were
introduced in 18.1; the other seven resources in `migration.md` were introduced
in 18.0. This was checked against the resource declarations in Chef 19.3.14.

## Release and archive sequence

1. Land the migration guide, corrected replacement minimum and narrow release
   CI dependency repair. Preserve the runtime code and existing test matrix.
2. Let release-please update the final 7.0.0 deprecation PR, currently #157.
3. Verify the required checks and meaningful integration evidence before merging
   the final release. Do not bypass failing checks to declare it verified.
4. Verify the GitHub release/tag and OCI publication for exactly 7.0.0. Record
   publication failures separately from the source merge.
5. Report the proposed archive-only action for review after the final release is
   published. Do not archive early or assume that retirement is already done.
6. After that review, archive the repository while preserving code, history,
   tags, releases, issues and registry artifacts. Do not delete the repository
   or packages, close historical issues, or change managed hosts.

## Open work at the retirement inventory

PR #157 is the only open PR. Issues #119, #118 and #114 are functional reports;
issue #98 is the Renovate dependency dashboard. Preserve those records. New functional
reports should be directed to `chef/chef`, as documented in the README.

## CI findings

The shared lint workflow generates a Ruby bundle without Berkshelf, while the
existing specs require `chefspec/berkshelf`. Supply `berkshelf` through its
existing `gems` input; do not change resource behaviour to fix that setup error.

The legacy integration matrix contains 75 VirtualBox jobs. Required branch
checks currently cover metadata, Cookstyle, RSpec, Markdown and YAML. The VM
matrix remains part of the evidence to assess; do not quietly disable or narrow
it merely to merge the release.

The CI Workstation provides the Cinc installer. Set `CHEF_PRODUCT_NAME=cinc` in
the VM test step, using kitchen.yml's existing override. Otherwise the VMs boot
successfully but convergence stops with `Unknown product name chef` before any
resource runs. Preserve all platform and suite combinations when fixing this
setup error.

Amazon Linux 2023 requires `policycoreutils-python-utils`, while Amazon Linux 2
keeps `policycoreutils-python`. Unit coverage checks both defaults; this is a
narrow compatibility fix and does not change the public `packages` property.
AWS lists the replacement package in its AL2023 package comparison:
<https://docs.aws.amazon.com/linux/al2023/ug/image-comparison.html>.

The retained Debian 11 VM fixture uses Debian's official main and security
archives after Bullseye's LTS end. Both archive Release endpoints returned HTTP
200 with the expected codenames and no `Valid-Until` field on 12 November 2026.
Keep APT signature verification enabled. A source-file change notifies the cache
refresh immediately; repeated converges do not force another update.

* <https://archive.debian.org/debian/dists/bullseye/Release>
* <https://archive.debian.org/debian-security/dists/bullseye-security/Release>
