module Deciding
  class SetInterestsOfJustice < Command
    attribute :user_id, Types::Uuid
    attribute :details, Types::InterestsOfJusticeDecision

    def call
      with_decision do |decision|
        decision.set_interests_of_justice(user_id:, details:)
      end
    end
  end
end
