require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'laa_crime_schemas'
require 'axe-rspec'

['init/*.rb', 'shared_contexts/*.rb', 'shared_examples/*.rb', 'support/*.rb'].each do |path|
  Dir[File.expand_path(path, __dir__)].each { |f| require f }
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--start-maximized')
  options.add_argument('--window-size=1980,2080')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.fixture_paths = Rails.root.join('/spec/fixtures')

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.include_context 'with a logged in user', type: :system

  # Use the faster rack test by default for system specs
  config.before(:each, type: :system) do |_example|
    driven_by :rack_test
  end

  # For time travel.
  config.include ActiveSupport::Testing::TimeHelpers
  config.include GdsHelper

  # Use a separate in-memory event store for each spec, instead of the
  # event store configured by the initializer. Having a separate store
  # for each spec reduces the surface area when working with events.
  # And running an in-memory repository reduces hits to the database.
  config.before do |_example|
    Rails.configuration.event_store = RailsEventStore::Client.new(
      repository: RubyEventStore::InMemoryRepository.new
    )
  end

  # Subscribe handlers generally required for the system specs.
  # Other handlers can be subscribed in a similar manner in the before
  # block if a spec requires it.
  config.before(:each, type: :system) do |_example|
    event_store = Rails.configuration.event_store

    CurrentAssignments::Configuration.new.call(event_store)
    Reviews::Configuration.new.call(event_store)
    CaseworkerReports::Configuration.new.call(event_store)
  end
end

RSpec::Matchers.define_negated_matcher :not_change, :change
