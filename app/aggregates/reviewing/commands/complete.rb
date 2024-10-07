module Reviewing
  class Complete < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call # rubocop:disable Metrics/MethodLength
      ActiveRecord::Base.transaction do
        with_review do |review|
          review.complete(user_id:)

          decisions = review.decision_ids.map do |decision_id|
            Deciding::LoadDecision.call(
              application_id:, decision_id:
            )
          end

          DatastoreApi::Requests::UpdateApplication.new(
            application_id: application_id,
            payload: { decisions: },
            member: :complete
          ).call
        end
      end
    end
  end
end
