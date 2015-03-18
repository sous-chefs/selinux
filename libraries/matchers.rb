if defined?(ChefSpec)

  def enforcing_selinux_state(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_state, :enforcing, resource_name)
  end

  def disabled_selinux_state(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_state, :disabled, resource_name)
  end

  def permissive_selinux_state(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_state, :permissive, resource_name)
  end

end
