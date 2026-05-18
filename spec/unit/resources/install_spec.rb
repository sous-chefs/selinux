require 'spec_helper'

describe 'selinux_install' do
  step_into :selinux_install
  platform 'centos'

  recipe do
    selinux_install 'test'
  end

  context 'on centos' do
    platform 'centos'

    it do
      is_expected.to install_package('selinux').with(
        package_name: %w(make policycoreutils policycoreutils-python-utils selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils setools-console)
      )
    end
  end

  context 'on fedora' do
    platform 'fedora'

    it do
      is_expected.to install_package('selinux').with(
        package_name: %w(make policycoreutils policycoreutils-python-utils selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils setools-console)
      )
    end
  end

  context 'on debian' do
    platform 'debian'

    it do
      is_expected.to install_package('selinux').with(
        package_name: %w(make policycoreutils selinux-basics selinux-policy-default selinux-policy-dev auditd setools)
      )
    end
  end

  context 'on ubuntu 24.04' do
    platform 'ubuntu', '24.04'

    it do
      is_expected.to install_package('selinux').with(
        package_name: %w(make policycoreutils selinux-basics selinux-policy-default selinux-policy-dev auditd setools)
      )
    end
  end

  context 'on amazon linux 2' do
    platform 'amazon', '2'

    it do
      is_expected.to install_package('selinux').with(
        package_name: %w(make policycoreutils policycoreutils-python selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils setools-console)
      )
    end
  end

  context 'on amazon linux 2023' do
    platform 'amazon', '2023'

    it do
      is_expected.to install_package('selinux').with(
        package_name: %w(make policycoreutils policycoreutils-python-utils selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils setools-console)
      )
    end
  end
end
