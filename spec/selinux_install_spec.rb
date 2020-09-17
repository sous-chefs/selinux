require 'spec_helper'

describe 'selinux_install_test::default' do
  shared_examples_for 'install selinux' do
    it 'install selinux' do
      expect(chef_run).to(
        ChefSpec::Matchers::ResourceMatcher.new(
          :selinux_install, :install, 'install packages'))
    end
  end

  context 'When user passes skip_mcs attribute as a false' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', step_into: ['selinux_install']) do |node|
        node.normal['selinux']['skip_mcs'] = false
      end.converge(described_recipe)
    end

    it_behaves_like 'install selinux'

    it 'install mcstrans package' do
      expect(chef_run).to install_package(%w(policycoreutils selinux-policy selinux-policy-targeted libselinux-utils mcstrans))
    end
  end

  context 'When user passes skip_mcs attribute as a true' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', step_into: ['selinux_install']) do |node|
        node.normal['selinux']['skip_mcs'] = true
      end.converge(described_recipe)
    end

    it_behaves_like 'install selinux'

    it 'does not install mcstrans package' do
      expect(chef_run).to install_package(%w(policycoreutils selinux-policy selinux-policy-targeted libselinux-utils))
    end
  end
end
