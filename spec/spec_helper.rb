# frozen_string_literal: true

require "micrograd"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random

  config.before(:suite) do
    srand(RSpec.configuration.seed)
  end
end

RSpec::Matchers.define :be_close_to do |expected|
  THRESHOLD = 0.0001 unless defined?(THRESHOLD)

  match do |actual|
    (actual - expected).abs <= THRESHOLD
  end

  failure_message do |actual|
    "expected #{actual} to be within #{THRESHOLD} of #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected #{actual} not to be within #{THRESHOLD} of #{expected}"
  end
end
