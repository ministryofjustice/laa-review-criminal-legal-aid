module Deciding
  class SubmitDecision < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid
    attribute :decision_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_decision do |decision|
          decision.submit(user_id:, decision_id:)
        end

        # DatastoreApi::Requests::UpdateApplication.new(
        #   application_id: application_id,
        #   payload: { return_details: },
        #   member: :return
        # ).call
      end
    end

    # private
    #
    # def reason
    #   return_details.fetch(:reason)
    # end
  end
end
