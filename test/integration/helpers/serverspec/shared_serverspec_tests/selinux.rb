require 'rspec'
require 'spec_helper'

RSpec.shared_examples 'selinux' do
  describe file('/etc/selinux/config') do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe command("/usr/sbin/getenforce") do
    if $node['selinux']['needs_reboot']
      desired = Regexp.new(/^(Disabled|Permissive)$/)
    else
      desired = Regexp.new($node['selinux']['state'].capitalize)
      # desired = $node['selinux']['state'] == 'enforcing' ?
      #   Regexp.new($node['selinux']['state'].capitalize) :
      #   Regexp.new(/^(Disabled|Permissive)$/)
    end
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(desired) }
  end
end
