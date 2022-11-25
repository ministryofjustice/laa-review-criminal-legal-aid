require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'init/event_store'
require 'init/api_data'
require 'init/webmock'
require 'shared_contexts/logged_in_user'

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.fixture_path = Rails.root.join('/spec/fixtures')

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.include_context 'with a logged in user', type: :system

  # Use the faster rack test by default for system specs
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end

RSpec::Matchers.define_negated_matcher :not_change, :change
