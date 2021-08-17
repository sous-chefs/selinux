module SELinuxPolicy
  module Cookbook
    module Helpers
      require 'chef/mixin/shell_out'
      include Chef::Mixin::ShellOut
      # Checks if SELinux is disabled or otherwise unavailable and
      # whether we're allowed to run when disabled
      def use_selinux(allow_disabled)
        begin
          getenforce = shell_out!('getenforce')
        rescue
          selinux_disabled = true
        else
          selinux_disabled = getenforce.stdout =~ /disabled/i
        end

        # return false only when SELinux is disabled and it's allowed
        return_val = !selinux_disabled || !(selinux_disabled && allow_disabled)
        Chef::Log.warn('SELinux is disabled / unreachable, skipping') unless return_val
        return_val
      end

      def module_defined(name)
        "semodule -l | grep -w '^#{name}'"
      end

      def shell_boolean(expression)
        expression ? 'true' : 'false'
      end

      def port_defined(protocol, port, label = nil)
        base_command = "seinfo --portcon=#{port} | grep 'portcon #{protocol}' | awk -F: '$(NF-1) !~ /reserved_port_t$/ && $(NF-3) !~ /[0-9]*-[0-9]*/ {print $(NF-1)}'"
        grep = if label
                 "grep -P '#{Regexp.escape(label)}'"
               else
                 'grep -q ^'
               end
        "#{base_command} | #{grep}"
      end

      def fcontext_defined(file_spec, file_type, label = nil)
        file_hash = {
          'a' => 'all files',
          'f' => 'regular file',
          'd' => 'directory',
          'c' => 'character device',
          'b' => 'block device',
          's' => 'socket',
          'l' => 'symbolic link',
          'p' => 'named pipe',
        }

        label_matcher = label ? "system_u:object_r:#{Regexp.escape(label)}:s0\\s*$" : ''
        "semanage fcontext -l | grep -qP '^#{Regexp.escape(file_spec)}\\s+#{Regexp.escape(file_hash[file_type])}\\s+#{label_matcher}'"
      end

      def semanage_options(file_type)
        # Set options for file_type
        if platform_family?('rhel') && node['platform_version'].to_i == 6
          case file_type
          when 'a' then '-f ""'
          when 'f' then '-f --'
          else; "-f -#{file_type}"
          end
        else
          "-f #{file_type}"
        end
      end
    end
  end
end

Chef::DSL::Recipe.include ::SELinuxPolicy::Cookbook::Helpers
Chef::Resource.include ::SELinuxPolicy::Cookbook::Helpers
