# Manages a port assignment in SELinux

unified_mode true

property :port, [Integer, String],
          name_property: true,
          regex: /^\d+$/,
          description: 'Port to modify'

property :protocol, String,
          equal_to: %w(tcp udp),
          required: %i(manage add modify),
          description: 'Protocol to modify'

property :secontext, String,
          required: %i(manage add modify),
          description: 'SELinux context to assign to the port'

action_class do
  include SELinux::Cookbook::StateHelpers

  def current_port_context
    # use awk to see if the given port is within a reported port range
    shell_out!(
      <<~CMD
        seinfo --portcon=#{new_resource.port} | grep 'portcon #{new_resource.protocol}' | \
        awk -F: '$(NF-1) !~ /reserved_port_t$/ && $(NF-3) !~ /[0-9]*-[0-9]*/ {print $(NF-1)}'
      CMD
    ).stdout.strip
  end
end

action :manage do
  run_action(:add)
  run_action(:modify)
end

action :addormodify do
  Chef::Log.warn('The :addormodify action for selinux_port is deprecated and will be removed in a future release. Use the :manage action instead.')
  run_action(:manage)
end

# Create if doesn't exist, do not touch if port is already registered (even under different type)
action :add do
  if selinux_disabled?
    Chef::Log.warn("Unable to add SELinux port #{new_resource.name} as SELinux is disabled")
    return
  end

  if current_port_context.empty?
    converge_by "Adding context #{new_resource.secontext} to port #{new_resource.port}/#{new_resource.protocol}" do
      shell_out!("semanage port -a -t '#{new_resource.secontext}' -p #{new_resource.protocol} #{new_resource.port}")
    end
  end
end

# Only modify port if it exists & doesn't have the correct context already
action :modify do
  if selinux_disabled?
    Chef::Log.warn("Unable to modify SELinux port #{new_resource.name} as SELinux is disabled")
    return
  end

  if !current_port_context.empty? && current_port_context != new_resource.secontext
    converge_by "Modifying context #{new_resource.secontext} to port #{new_resource.port}/#{new_resource.protocol}" do
      shell_out!("semanage port -m -t '#{new_resource.secontext}' -p #{new_resource.protocol} #{new_resource.port}")
    end
  end
end

# Delete if exists
action :delete do
  if selinux_disabled?
    Chef::Log.warn("Unable to delete SELinux port #{new_resource.name} as SELinux is disabled")
    return
  end

  unless current_port_context.empty?
    converge_by "Deleting context from port #{new_resource.port}/#{new_resource.protocol}" do
      shell_out!("semanage port -d -p #{new_resource.protocol} #{new_resource.port}")
    end
  end
end
