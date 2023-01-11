module Reviewing
  class Complete < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      with_review do |review|
        review.complete(application_id:, user_id:)
      end
    end
  end
end
