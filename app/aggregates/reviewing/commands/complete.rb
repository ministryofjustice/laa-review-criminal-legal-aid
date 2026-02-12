module Reviewing
  class Complete < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_review(user_id:) do |review|
          review.complete(user_id:)

          review.decision_ids.each do |decision_id|
            Deciding::SendToProvider.call(user_id:, application_id:, decision_id:)
          end
        end
      end
    rescue Deciding::IncompleteDecision
      raise Reviewing::IncompleteDecisions
    end
  end
end
