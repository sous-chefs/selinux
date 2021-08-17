# Manages a port assignment in SELinux

unified_mode true

property :port, [Integer, String],
          name_property: true,
          regex: /^\d+$/

property :protocol, String,
          equal_to: %w(tcp udp),
          required: %i(addormodify add modify)

property :secontext, String,
          required: %i(addormodify add modify)

property :allow_disabled, [true, false],
          default: true

action :addormodify do
  # TODO: We can be a bit more clever here, and try to detect if it's already there then modify
  run_action(:add)    # Try to add new port
  run_action(:modify) # Try to modify existing port
end

# Create if doesn't exist, do not touch if port is already registered (even under different type)
action :add do
  execute "selinux-port-#{new_resource.port}-add" do
    command "semanage port -a -t #{new_resource.secontext} -p #{new_resource.protocol} #{new_resource.port}"
    not_if port_defined(new_resource.protocol, new_resource.port)
    only_if { use_selinux(new_resource.allow_disabled) }
  end
end

# Only modify port if it exists & doesn't have the correct context already
action :modify do
  execute "selinux-port-#{new_resource.port}-modify" do
    command "semanage port -m -t #{new_resource.secontext} -p #{new_resource.protocol} #{new_resource.port}"
    only_if port_defined(new_resource.protocol, new_resource.port)
    not_if port_defined(new_resource.protocol, new_resource.port, new_resource.secontext)
    only_if { use_selinux(new_resource.allow_disabled) }
  end
end

# Delete if exists
action :delete do
  execute "selinux-port-#{new_resource.port}-delete" do
    command "semanage port -d -p #{new_resource.protocol} #{new_resource.port}"
    only_if port_defined(new_resource.protocol, new_resource.port)
    only_if { use_selinux(new_resource.allow_disabled) }
  end
end
