module Authorising
  class Invited < RailsEventStore::Event; end
  class InviteRenewed < RailsEventStore::Event; end
  class InviteRevoked < RailsEventStore::Event; end
  class Activated < RailsEventStore::Event; end
  class Deactivated < RailsEventStore::Event; end
  class Reactivated < RailsEventStore::Event; end
  class RevivalAwaited < RailsEventStore::Event; end
  class Revived < RailsEventStore::Event; end

  class << self
    def user_events(user_id)
      Rails.application.config.event_store.read.stream(stream_name(user_id))
    end

    def stream_name(user_id)
      "Authorisation$#{user_id}"
    end
  end
end
