require 'serverspec'
require 'json'

set :backend, :exec

$node = ::JSON.parse(File.read('/tmp/kitchen/chef_node.json'))
