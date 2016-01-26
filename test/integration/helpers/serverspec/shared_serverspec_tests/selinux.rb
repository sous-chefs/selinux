require 'rspec'
require 'spec_helper'

RSpec.shared_examples 'selinux' do
  describe command("/usr/sbin/getenforce") do
    if $node['selinux']['needs_reboot']
      desired = Regexp.new(/^(Disabled|Permissive)$/)
    else
      desired = Regexp.new($node['selinux']['state'].capitalize)
    end
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(desired) }
  end
end
