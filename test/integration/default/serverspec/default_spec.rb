require 'spec_helper'
require_relative '../serverspec/shared_serverspec_tests/selinux.rb'

describe "selinux #{$node['selinux']['state']}" do
  include_examples 'selinux'
end
