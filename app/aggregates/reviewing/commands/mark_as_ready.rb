module Reviewing
  class MarkAsReady < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      ActiveRecord::Base.transaction do
        with_review(&:mark_as_ready)
      end
    end
  end
end
