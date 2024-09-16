module Deciding
  class CreateDraft < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        decision.create_draft(user_id:, application_id:)
      end
    end
  end
end
