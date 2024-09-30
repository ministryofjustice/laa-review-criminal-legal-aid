module Deciding
  class CreateDraftFromMaat < Command
    attribute :application_id, Types::Uuid
    attribute :maat_decision, Maat::Decision
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        decision.create_draft_from_maat(
          application_id:, maat_decision:, user_id:
        )
      end
    end
  end
end
