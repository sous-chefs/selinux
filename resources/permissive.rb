# a resource for managing selinux permissive contexts

unified_mode true

property :context, String,
          name_property: true

property :allow_disabled, [true, false],
          default: true

# Create if doesn't exist, do not touch if permissive is already registered (even under different type)
action :add do
  execute "selinux-permissive-#{new_resource.context}-add" do
    command "#{semanage_cmd} permissive -a '#{new_resource.context}'"
    not_if  "#{semanage_cmd} permissive -l | grep -Fxq '#{new_resource.context}'"
    only_if { use_selinux(new_resource.allow_disabled) }
  end
end

# Delete if exists
action :delete do
  execute "selinux-permissive-#{new_resource.context}-delete" do
    command "#{semanage_cmd} permissive -d '#{new_resource.context}'"
    only_if "#{semanage_cmd} permissive -l | grep -Fxq '#{new_resource.context}'"
    only_if { use_selinux(new_resource.allow_disabled) }
  end
end
