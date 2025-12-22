module Reviewing
  class MarkAsReady < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_review(user_id:) do |review|
          review.mark_as_ready(user_id:)
        end

        DatastoreApi::Requests::UpdateApplication.new(
          application_id: application_id,
          payload: true,
          member: :mark_as_ready
        ).call
      end
    end
  end
end
