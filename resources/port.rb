# Manages a port assignment in SELinux

unified_mode true

property :port, [Integer, String],
          name_property: true,
          regex: /^\d+$/,
          description: 'Port to modify'

property :protocol, String,
          equal_to: %w(tcp udp),
          required: %i(addormodify add modify),
          description: 'Protocol to modify'

property :secontext, String,
          required: %i(addormodify add modify),
          description: 'SELinux context to assign to the port'

action_class do
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

action :addormodify do
  # TODO: We can be a bit more clever here, and try to detect if it's already there then modify
  run_action(:add)    # Try to add new port
  run_action(:modify) # Try to modify existing port
end

# Create if doesn't exist, do not touch if port is already registered (even under different type)
action :add do
  if current_port_context.empty?
    converge_by "Adding context #{new_resource.secontext} to port #{new_resource.port}/#{new_resource.protocol}" do
      shell_out!("semanage port -a -t #{new_resource.secontext} -p #{new_resource.protocol} #{new_resource.port}")
    end
  end
end

# Only modify port if it exists & doesn't have the correct context already
action :modify do
  if !current_port_context.empty? && current_port_context != new_resource.secontext
    converge_by "Modifying context #{new_resource.secontext} to port #{new_resource.port}/#{new_resource.protocol}" do
      shell_out!("semanage port -m -t #{new_resource.secontext} -p #{new_resource.protocol} #{new_resource.port}")
    end
  end
end

# Delete if exists
action :delete do
  unless current_port_context.empty?
    converge_by "Deleting context from port #{new_resource.port}/#{new_resource.protocol}" do
      shell_out!("semanage port -d -p #{new_resource.protocol} #{new_resource.port}")
    end
  end
end
