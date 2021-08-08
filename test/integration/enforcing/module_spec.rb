describe selinux.modules.where(name: 'test') do
  it { should exist }
  it { should be_installed }
  it { should be_enabled }
end

if os.family.eql?('debian')
  describe selinux.modules.where(name: 'moduleLoad') do
    it { should exist }
    it { should be_installed }
    it { should be_enabled }
  end

  describe selinux.modules.where(name: 'kitchenVerify') do
    it { should exist }
    it { should be_installed }
    it { should be_enabled }
  end
end
