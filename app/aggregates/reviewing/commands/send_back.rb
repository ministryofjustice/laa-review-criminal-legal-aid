module Reviewing
  class SendBack < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid
    attribute :return_details, Types::ReturnDetails

    def call
      ActiveRecord::Base.transaction do
        with_review do |review|
          review.send_back(user_id:, reason:)
        end

        update_datastore
      end
    end

    private

    def update_datastore
      DatastoreApi::Requests::UpdateApplication.new(
        application_id: application_id,
        payload: { return_details: },
        member: :return
      ).call
    end

    def reason
      return_details.fetch(:reason)
    end
  end
end
