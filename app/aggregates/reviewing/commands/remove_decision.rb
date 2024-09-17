module Reviewing
  class RemoveDecision < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid
    attribute :decision_id, Types::Uuid

    def call
      with_review do |review|
        review.remove_decision(user_id:, decision_id:)
      end
    end
  end
end
