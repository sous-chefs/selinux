module SELinux
  module Cookbook
    module StateHelpers
      def default_policy_platform
        case node['platform_family']
        when 'rhel', 'fedora', 'amazon'
          'targeted'
        when 'debian'
          'default'
        end
      end
    end
  end
end
