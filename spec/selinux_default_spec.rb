require 'spec_helper'

def stub_selinux_semodule(runner)
  expect(Mixlib::ShellOut).to receive(:new).and_return(runner)
  expect(runner).to receive(:run_command)
  expect(runner).to receive(:stderr).and_return('')
  expect(runner).to receive(:stdout).and_return(<<-EOS
abrt       1.4.1
accountsd  1.1.0
acct       1.6.0
afs        1.9.0
aiccu      1.1.0
aide       1.7.1
ajaxterm   1.0.0
alsa       1.12.2
EOS
  )
end

describe 'selinux_default_test::default' do
  before { stub_selinux_semodule(double) }

  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['selinux']).converge(described_recipe)
  end

  let(:selinux_file) { '/etc/selinux/local/test.te' }
  let(:sefile) { SELinux::File.new(selinux_contents) }
  let(:selinux_contents) do
    File.open(
      File.expand_path(
        './test/fixtures/cookbooks/selinux_default_test/files/selinux/test.te')
    ).read
  end
  let(:module_name) { 'aiccu' }
  let(:module_version) { '1.1.0' }
  let(:semodule) { SELinux::Module.new(@module_name) }


  it 'create (install) `test` selinux module' do # ~FC005
    expect(chef_run).to(
      render_file(selinux_file).with_content(selinux_contents))
  end

#  it 'remove `test` selinux module' do
#    expect(chef_run).to selinux_default_remove('remove')
#  end

# it 'creates the default directory and deploy test.te file' do # ~FC005
#   expect(chef_run).to create_directory(File.dirname(selinux_file))
#   expect(chef_run).to create_file(selinux_file)
# end

# it 'installs the required packages to compile a semodule' do
#   expect(chef_run).to install_yum_package('make')
#   expect(chef_run).to install_yum_package('policycoreutils')
# end

# it 'runs make command and installs module' do
#   expect(chef_run).to run_execute(/make/)
#   expect(chef_run).to run_execute(/semodule/)
# end

# it 'should be able to check for a installed module and version' do
#   expect(semodule.installed?).to be true
#   expect(semodule.installed?(module_version)).to be true
#   expect(semodule.installed?('9.9.9')).to be false
# end

# it 'should be a SELinux::File type' do
#   expect(sefile).to be_a SELinux::File
# end

# it 'should be able to extract the version and module name' do
#   expect(sefile.version).to be == '0.1'
#   expect(sefile.module_name).to be == 'test'
# end

# it 'should be able to read contents' do
#   expect(sefile.content).to be == selinux_contents
# end
end

# EOF
