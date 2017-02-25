if defined?(ChefSpec)
  ChefSpec.define_matcher :selinux_state

  def enforcing_selinux_state(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_state, :enforcing, resource_name)
  end

  def disabled_selinux_state(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_state, :disabled, resource_name)
  end

  def permissive_selinux_state(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_state, :permissive, resource_name)
  end

  ChefSpec.define_matcher :selinux_install

  def install_selinux_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_install, :install, resource_name)
  end
end
