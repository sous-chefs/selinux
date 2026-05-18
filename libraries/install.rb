# frozen_string_literal: true

module SELinux
  module Cookbook
    module InstallHelpers
      def default_install_packages
        case node['platform_family']
        when 'rhel'
          %w(make policycoreutils policycoreutils-python-utils selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils setools-console)
        when 'amazon'
          if node['platform_version'].to_i >= 2023
            %w(make policycoreutils policycoreutils-python-utils selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils setools-console)
          else
            %w(make policycoreutils policycoreutils-python selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils setools-console)
          end
        when 'fedora'
          %w(make policycoreutils policycoreutils-python-utils selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils setools-console)
        when 'debian'
          %w(make policycoreutils selinux-basics selinux-policy-default selinux-policy-dev auditd setools)
        end
      end
    end
  end
end
