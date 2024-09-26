Rails.configuration.to_prepare do
  event_store = Rails.configuration.event_store = RailsEventStore::Client.new

  Deciding::Configuration.new.call(event_store)

  #Notifying
  NotifierConfiguration.new.call(event_store)
  
  #Read Models
  CurrentAssignments::Configuration.new.call(event_store)
  ReceivedOnReports::Configuration.new.call(event_store)
  Reviews::Configuration.new.call(event_store)
  CaseworkerReports::Configuration.new.call(event_store)

end
