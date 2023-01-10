module Reviewing
  class ReceiveApplication < Command
    attribute :application_id, Types::Uuid

    def call
      with_review do |review|
        review.receive_application(application_id:)
      end
    end
  end
end
