module Deciding
  class CreateDraft < Command
    attribute :application_id, Types::Uuid
    attribute :user_id, Types::Uuid
    attribute :reference, Types::Integer

    def call
      with_decision do |decision|
        decision.create_draft(user_id:, application_id:, reference:)
      end
    end
  end
end
