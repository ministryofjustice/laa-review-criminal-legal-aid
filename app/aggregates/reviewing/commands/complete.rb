module Reviewing
  class Complete < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_review do |review|
          review.complete(user_id:)

          DatastoreApi::Requests::UpdateApplication.new(
            application_id: application_id,
            payload: { decisions: decisions(review) },
            member: :complete
          ).call
        end
      end
    end

    private

    def decisions(review)
      draft_decisions(review).map do |draft|
        LaaCrimeSchemas::Structs::Decision.new(draft).as_json
      end
    end

    def draft_decisions(review)
      review.decision_ids.map do |decision_id|
        decision = Deciding::LoadDecision.call(
          application_id:, decision_id:
        )

        raise IncompleteDecisions unless decision.complete?

        Decisions::Draft.build(decision)
      end
    end
  end
end
