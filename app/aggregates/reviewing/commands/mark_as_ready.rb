module Reviewing
  class MarkAsReady < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_review do |review|
          review.mark_as_ready(user_id:)
        end
      end
    end
  end
end
