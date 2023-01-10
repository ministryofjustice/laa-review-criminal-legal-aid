module Reviewing
  class SendBack < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid
    attribute :reason, Types::ReturnReason

    def call
      with_review do |review|
        review.send_back(application_id:, reason:, user_id:)
      end
    end
  end
end
