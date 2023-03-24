require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'laa_crime_schemas'
require 'axe-rspec'

Dir[File.expand_path('init/*.rb', __dir__)].each { |f| require f }
Dir[File.expand_path('shared_contexts/*.rb', __dir__)].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

OmniAuth.config.test_mode = true

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
  config.fixture_path = Rails.root.join('/spec/fixtures')

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.include_context 'with a logged in user', type: :system

  # Use the faster rack test by default for system specs
  config.before(:each, type: :system) do |example|
    driven_by :rack_test
  end

  # For time travel.
  config.include ActiveSupport::Testing::TimeHelpers
end

RSpec::Matchers.define_negated_matcher :not_change, :change
