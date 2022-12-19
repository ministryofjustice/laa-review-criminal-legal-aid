module Assigning
  class AssignedToUser < RailsEventStore::Event
  end

  class UnassignedFromUser < RailsEventStore::Event
  end

  class ReassignedToUser < RailsEventStore::Event
  end
end
