require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  fixture_modules = File.join(proj_root, 'spec', 'fixtures', 'modules')

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      host.install_package "rsync"
      # Install this module, this is required because symlinks are not transferred in the step below
      copy_module_to(host, :source => proj_root, :module_name => 'couchbase')
      # copies all the fixtures over
      rsync_to(host ,fixture_modules, '/etc/puppet/modules/')
    end
  end
end
