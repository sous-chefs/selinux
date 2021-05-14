describe selinux.modules.where(name: 'test') do
  it { should exist }
  it { should be_installed }
  it { should be_enabled }
end
