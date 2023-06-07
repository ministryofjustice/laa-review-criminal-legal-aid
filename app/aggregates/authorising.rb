module Authorising
  class Invited < RailsEventStore::Event; end
  class InviteRenewed < RailsEventStore::Event; end
  class InviteRevoked < RailsEventStore::Event; end
  class Activated < RailsEventStore::Event; end
  class Deactivated < RailsEventStore::Event; end
  class Reactivated < RailsEventStore::Event; end
end
