if platform?('debian') && node['platform_version'].to_i == 11
  file '/etc/apt/sources.list' do
    content <<~SOURCES
      deb https://archive.debian.org/debian bullseye main contrib non-free
      deb https://archive.debian.org/debian-security bullseye-security main contrib non-free
    SOURCES
    notifies :update, 'apt_update[default]', :immediately
  end
end

apt_update 'default' if platform_family?('debian')

selinux_install 'install packages'
