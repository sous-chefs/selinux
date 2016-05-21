module SELinux
  # Static methods to help on provider actions
  module Helpers
    # Easy way to stub '::File' responses.
    def file_exists?(file_path)
      ::File.exists?(file_path)
    end
  end
end

# EOF
