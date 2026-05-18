# frozen_string_literal: true

include_controls 'common'

control 'default-install' do
  title 'Verify the default suite converges through custom resources'

  describe directory('/etc/selinux') do
    it { should exist }
    it { should be_directory }
  end
end
