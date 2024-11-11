module Reviewing
  class Complete < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_review do |review|
          review.draft_decisions.each do |draft|
            draft.send_to_provider(user_id:, application_id:)
          end

          review.complete(user_id:)

          DatastoreApi::Requests::UpdateApplication.new(
            application_id: application_id,
            payload: { decisions: decisions(review)},
            member: :complete
          ).call
        end
      end
    end

    private

    def decisions(review)
      review.draft_decisions.map do |draft|
        Decisions::Draft.build(draft).as_json
      end
    end
  end
end
