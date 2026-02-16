module ReferenceHistory
  HISTORY_EVENTS = [
    Assigning::AssignedToUser,
    Assigning::UnassignedFromUser,
    Assigning::ReassignedToUser,
    Reviewing::ApplicationReceived,
    Reviewing::SentBack,
    Reviewing::Completed,
    Reviewing::MarkedAsReady,
    Deleting::SoftDeleted,
    Deleting::Archived,
  ].freeze

  class << self
    def stream_name(reference)
      "ReferenceHistory$#{reference}"
    end
  end
end
