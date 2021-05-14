describe selinux.modules.where(name: 'test') do
  it { should_not exist }
  it { should_not be_installed }
  it { should_not be_enabled }
end
