module SELinux
  module Install
    def default_install_packages
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        %w(policycoreutils selinux-policy selinux-policy-targeted libselinux-utils)
      when 'debian'
        %w(selinux-basics selinux-policy-default auditd)
      end
    end

    def default_install_packages_policy
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        %w(make policycoreutils selinux-policy-devel)
      when 'debian'
        %w(make policycoreutils selinux-policy-dev)
      end
    end
  end
end
