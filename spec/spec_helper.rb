require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'linkeddata'
require 'rdf/vocab'
require 'bundler/setup'
Bundler.setup

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.color = true
  config.tty = true

  # Uncomment the following line to get errors and backtrace for deprecation warnings
  # config.raise_errors_for_deprecations!

  # Use the specified formatter
  config.formatter = :progress
end
