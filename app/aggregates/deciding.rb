module Deciding
  class AlreadyCreated < Error; end
  class AlreadyLinked < Error; end
  class ApplicationNotAssignedToUser < Error; end
  class DecisionNotFound < Error; end
  class MaatRecordNotChanged < Error; end
  class ReferenceMismatch < Error; end

  class CommentSet < Event; end
  class DraftCreated < Event; end
  class DraftCreatedFromMaat < Event; end
  class FundingDecisionSet < Event; end
  class InterestsOfJusticeSet < Event; end
  class Linked < Event; end
  class LinkedToCifc < Event; end
  class SentToProvider < Event; end
  class SynchedWithMaat < Event; end
  class Unlinked < Event; end

  class << self
    def stream_name(decision_id)
      "Deciding$#{decision_id}"
    end
  end

  # TODO: REMVOE

  class Sent < Event; end

  # class Configuration
  #   def call(event_store)
  #     event_store.subscribe(
  #       DecisionHandler, to: [Reviewing::AddDecision]
  #     )
  #   end
  # end
  #
  # class DecisionHandler
  #   def call(event); end
  # end
end
