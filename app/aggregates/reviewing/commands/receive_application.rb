module Reviewing
  class ReceiveApplication < Command
    attribute :application_id, Types::Uuid
    attribute? :correlation_id, Types::Uuid.optional

    def call
      with_review do |review|
        review.receive_application(application_id:, correlation_id:)
      end
    end
  end
end
