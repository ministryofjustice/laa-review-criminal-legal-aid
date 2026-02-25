module ReferenceHistory
  HISTORY_EVENTS = [
    Assigning::AssignedToUser,
    Assigning::UnassignedFromUser,
    Assigning::ReassignedToUser,
    Reviewing::ApplicationReceived,
    Reviewing::SentBack,
    Reviewing::Completed,
    Reviewing::MarkedAsReady,
    Reviewing::DecisionAdded,
    Reviewing::DecisionRemoved,
    Deciding::DraftCreated,
    Deciding::DraftCreatedFromMaat,
    Deciding::SynchedWithMaat,
    Deciding::InterestsOfJusticeSet,
    Deciding::FundingDecisionSet,
    Deciding::CommentSet,
    Deciding::Unlinked,
    Deciding::Linked,
    Deciding::LinkedToCifc,
    Deciding::LinkedToNafi,
    Deciding::SentToProvider
  ].freeze

  class << self
    def stream_name(reference)
      "ReferenceHistory$#{reference}"
    end
  end
end
