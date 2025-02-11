module Deciding
  class CreateDraftFromMaat < Command
    attribute :maat_decision, Decisions::Draft
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        if decision.state.present?
          decision.sync_with_maat(maat_decision:, user_id:)
        else
          decision.create_draft_from_maat(maat_decision:, user_id:)
        end
      end
    end
  end
end
