# a resource for managing selinux permissive contexts

unified_mode true

property :context, String,
          name_property: true,
          description: 'The SELinux context to permit'

action_class do
  def current_permissives
    shell_out!('semanage permissive -ln').stdout.split("\n")
  end
end

# Create if doesn't exist, do not touch if permissive is already registered (even under different type)
action :add do
  unless current_permissives.include? new_resource.context
    converge_by "adding permissive context #{new_resource.context}" do
      shell_out!("semanage permissive -a '#{new_resource.context}'")
    end
  end
end

# Delete if exists
action :delete do
  if current_permissives.include? new_resource.context
    converge_by "deleting permissive context #{new_resource.context}" do
      shell_out!("semanage permissive -a '#{new_resource.context}'")
    end
  end
end
