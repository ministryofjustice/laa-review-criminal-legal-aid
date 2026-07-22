module Authorising
  class Invited < RubyEventStore::Event; end
  class InviteRenewed < RubyEventStore::Event; end
  class InviteRevoked < RubyEventStore::Event; end
  class Activated < RubyEventStore::Event; end
  class Deactivated < RubyEventStore::Event; end
  class Reactivated < RubyEventStore::Event; end
  class RevivalAwaited < RubyEventStore::Event; end
  class Revived < RubyEventStore::Event; end
  class RoleChanged < RubyEventStore::Event; end

  class << self
    def user_events(user_id)
      Rails.application.config.event_store.read.stream(stream_name(user_id))
    end

    def stream_name(user_id)
      "Authorisation$#{user_id}"
    end
  end
end
