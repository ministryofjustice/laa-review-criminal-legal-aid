RSpec.configure do |config|
  config.before do
    @configured_event_store = Rails.configuration.event_store

    Rails.configuration.event_store = RailsEventStore::Client.new(
      repository: RubyEventStore::InMemoryRepository.new
    )
  end

  config.after do
    Rails.configuration.event_store = @configured_event_store
  end
end
