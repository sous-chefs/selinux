module SELinux
  module Cookbook
    module InstallHelpers
      def default_install_packages
        case node['platform']
        when 'redhat', 'centos', 'fedora', 'amazon'
          %w(make policycoreutils selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils)
        when 'debian'
          %w(make policycoreutils selinux-basics selinux-policy-default selinux-policy-dev auditd)
        when 'ubuntu'
          if node['platform_version'].to_f == 18.04
            %w(make policycoreutils selinux selinux-basics selinux-policy-default selinux-policy-dev auditd)
          else
            %w(make policycoreutils selinux-basics selinux-policy-default selinux-policy-dev auditd)
          end
        end
      end
    end
  end
end
