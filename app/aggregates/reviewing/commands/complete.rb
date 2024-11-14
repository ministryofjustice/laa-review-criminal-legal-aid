module Reviewing
  class Complete < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_review do |review|
          review.complete(user_id:)

          review.decision_ids.each do |decision_id|
            Deciding::SendToProvider.call(user_id:, application_id:, decision_id:)
          end

          update_datastore(review)
        end
      end
    rescue Deciding::IncompleteDecision
      raise Reviewing::IncompleteDecisions
    end

    private

    def update_datastore(review)
      decisions = review.draft_decisions.map do |draft|
        Decisions::Draft.build(draft)
      end

      DatastoreApi::Requests::UpdateApplication.new(
        application_id: application_id,
        payload: { decisions: },
        member: :complete
      ).call
    end
  end
end
