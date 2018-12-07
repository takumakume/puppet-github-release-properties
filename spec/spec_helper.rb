require 'puppetlabs_spec_helper/module_spec_helper'
require 'vcr'

RSpec.configure do |c|
  c.before :each do
    Puppet.settings[:strict] = :warning
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
