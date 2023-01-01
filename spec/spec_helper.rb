ENV['RAILS_ENV'] ||= 'test'
require ::File.expand_path('../lib/boreas/application', __dir__)

require 'rspec/rails'

require 'capybara/rails'
require 'capybara/rspec'

require 'webmock/rspec'

RSpec.configure do |config|
  # good defaults
  config.order = :random
  Kernel.srand config.seed

  config.warnings = true

  config.disable_monkey_patching!

  config.filter_run_when_matching :focus

  # file fixtures are all we need
  config.file_fixture_path = 'spec/fixtures'
  
  # use pretty formatter for one spec file
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
  
  # these become defaults in rspec 4
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
