pkgs = if os.debian?
         %w(make policycoreutils selinux-basics selinux-policy-default selinux-policy-dev auditd)
       elsif os.redhat? && os.release.to_i == 6
         %w(make policycoreutils selinux-policy selinux-policy-targeted libselinux-utils)
       else
         %w(make policycoreutils selinux-policy selinux-policy-targeted selinux-policy-devel libselinux-utils)
       end

pkgs.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end
