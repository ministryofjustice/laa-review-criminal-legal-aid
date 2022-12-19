Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new
  
  Configuration.new.call(Rails.configuration.event_store)
end
