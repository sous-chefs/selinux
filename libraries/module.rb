module SELinux
  module Cookbook
    module ModuleHelpers
      include Chef::Mixin::ShellOut

      extend self

      def installed?(module_name)
        return true if list_installed_modules.include?(module_name)

        false
      end

      private

      def list_installed_modules
        shell_out!('/usr/sbin/semodule --list-modules', returns: [0]).stdout.split("\n").map { |m| m.split("\t").first }
      end
    end
  end
end
