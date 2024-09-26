module Deciding
  class SetInterestsOfJustice < Command
    attribute :user_id, Types::Uuid
    attribute :result, Types::InterestsOfJusticeResult
    attribute :details, Types::String
    attribute :assessed_by, Types::String
    attribute :assessed_on, Types::Date

    def call
      with_decision do |decision|
        decision.set_interests_of_justice(
          user_id: user_id,
          interests_of_justice: Types::InterestsOfJusticeDecision[**attributes]
        )
      end
    end
  end
end
