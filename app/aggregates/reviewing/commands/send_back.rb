module Reviewing
  class SendBack < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid
    attribute :return_details, Types::ReturnDetails

    def call
      ActiveRecord::Base.transaction do
        with_review do |review|
          review.send_back(application_id:, user_id:, reason:)
        end

        # TODO: Call http client
      end
    end

    private

    def reason
      return_details.fetch(:reason)
    end
  end
end
