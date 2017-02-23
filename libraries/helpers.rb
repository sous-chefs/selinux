module SelinuxCookbook
  module Helpers
    def config_file_dir
      '/etc/selinux'
    end

    def default_package_name
      return 'selinux-utils' if node['platform_family'] == 'debian'
      return 'libselinux-utils' if node['platform_family'] == 'rhel'
      raise "#{node[:platform_family]} not supported!"
    end
  end
end
