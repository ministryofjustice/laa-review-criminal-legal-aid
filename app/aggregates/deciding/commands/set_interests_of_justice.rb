module Deciding
  class SetInterestsOfJustice < Command
    attribute :user_id, Types::Uuid
    attribute :result, Types::InterestsOfJusticeResult
    attribute :details, Types::String
    attribute :assessed_by, Types::String
    attribute :assessed_on, Types::Date

    def call
      with_decision do |decision|
        interests_of_justice = LaaCrimeSchemas::Structs::TestResult.new(result:, details:, assessed_by:, assessed_on:)

        decision.set_interests_of_justice(user_id:, interests_of_justice:)
      end
    end
  end
end
