module Reviewing
  class ReceiveApplication < Command
    attribute :application_id, Types::Uuid
    attribute :submitted_at, Types::DateTime
    attribute? :parent_id, Types::Uuid.optional
    attribute? :correlation_id, Types::Uuid.optional
    attribute? :causation_id, Types::Uuid.optional

    def call
      with_review do |review|
        review.receive_application(submitted_at:, parent_id:)
      end
    end
  end
end
