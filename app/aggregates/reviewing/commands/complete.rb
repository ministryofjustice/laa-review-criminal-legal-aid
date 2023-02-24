module Reviewing
  class Complete < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_review do |review|
          review.complete(user_id:)
        end

        DatastoreApi::Requests::UpdateApplication.new(
          application_id: application_id,
          payload: true,
          member: :complete
        ).call
      end
    end
  end
end
