module Deciding
  class SetInterestsOfJustice < Command
    attribute :user_id, Types::Uuid
    attribute :interests_of_justice, Types::InterestsOfJusticeDecision

    def call
      with_decision do |decision|
        decision.set_interests_of_justice(user_id:, interests_of_justice:)
      end
    end
  end
end
