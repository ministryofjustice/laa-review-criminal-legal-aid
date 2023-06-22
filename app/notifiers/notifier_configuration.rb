class NotifierConfiguration
  def call(event_store)
    event_store.subscribe(
      AccessGrantedNotifier, to: [Authorising::Invited]
    )

    event_store.subscribe(
      SentBackNotifier, to: [Reviewing::SentBack]
    )
  end
end
