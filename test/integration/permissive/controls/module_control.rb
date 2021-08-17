control 'module' do
  title 'Verify that SELinux modules are installed correctly'

  describe selinux.modules.where(name: 'test') do
    it { should_not exist }
    it { should_not be_installed }
    it { should_not be_enabled }
  end
end
