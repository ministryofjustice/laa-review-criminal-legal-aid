module Reviewing
  class AddDecision < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid
    attribute :decision_id, Types::DecisionId

    def call
      with_review(user_id:) do |review|
        review.add_decision(user_id:, decision_id:)
      end
    end
  end
end
