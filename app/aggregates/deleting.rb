module Deleting
  class Event < RailsEventStore::Event; end
  class SoftDeleted < Event; end
  class Archived < Event; end
end
