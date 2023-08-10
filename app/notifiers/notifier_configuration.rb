class NotifierConfiguration
  SUBSCRIBERS = {
    AccessGrantedNotifier => [Authorising::Invited],
    SentBackNotifier => [Reviewing::SentBack],
    RoleChangedNotifier => [Authorising::RoleChanged],
    # TODO: RevivalAwaitedNotifier => [Authorising::RevivalAwaited],
  }.freeze

  def call(event_store)
    SUBSCRIBERS.each do |subscriber, events|
      event_store.subscribe(subscriber, to: events)
    end
  end
end
