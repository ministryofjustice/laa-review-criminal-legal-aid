require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'

Dir[
  Rails.root.join('spec/support/**/*.rb'),
  Rails.root.join('spec/init/*.rb')
].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# rubocop:disable Style/TrivialAccessors
def current_user_id
  @current_user_id
end
# rubocop:enable Style/TrivialAccessors
#
RSpec.configure do |config|
  application_ids = %w[
    696dd4fd-b619-4637-ab42-a5f4565bcf4a
    1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc
  ]

  config.before do
    @current_user_id = SecureRandom.hex
    OmniAuth.config.mock_auth[:azure_ad] = OmniAuth::AuthHash.new(
      {
        provider: 'azure_ad',
        uid: current_user_id,
        info: {
          id: current_user_id,
          email: 'Joe.EXAMPLE@justice.gov.uk',
          first_name: 'Joe',
          last_name: 'EXAMPLE',
          roles: ['caseworker']
        }
      }
    )

    @configured_event_store = Rails.configuration.event_store

    Rails.configuration.event_store = RailsEventStore::Client.new(repository: RubyEventStore::InMemoryRepository.new)

    stub_request(:get, "#{ENV.fetch('CRIME_APPLY_API_URL')}applications")
      .to_return(
        { body: file_fixture('crime_apply_data/applications.json').read },
        status: 200
      )

    application_ids.each do |application_id|
      stub_request(:get, "#{ENV.fetch('CRIME_APPLY_API_URL')}applications/#{application_id}")
        .to_return(
          body: file_fixture("crime_apply_data/applications/#{application_id}.json").read,
          status: 200
        )
    end
  end

  config.after do
    Rails.configuration.event_store = @configured_event_store
  end

  config.before do
    OmniAuth.config.test_mode = true
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Use the faster rack test by default for system specs
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end

RSpec::Matchers.define_negated_matcher :not_change, :change
