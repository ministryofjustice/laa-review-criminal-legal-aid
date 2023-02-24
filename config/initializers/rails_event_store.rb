Rails.configuration.to_prepare do
  event_store = Rails.configuration.event_store = RailsEventStore::Client.new
  
  CurrentAssignments::Configuration.new.call(event_store)
  ReceivedOnReports::Configuration.new.call(event_store)
end
