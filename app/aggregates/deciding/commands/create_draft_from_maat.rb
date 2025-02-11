module Deciding
  class CreateDraftFromMaat < Command
    attribute :maat_decision, Decisions::Draft
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        if decision.state.present?
          decision.sync_with_maat(maat_decision:, user_id:) if maat_decision&.checksum != decision.checksum
        else
          decision.create_draft_from_maat(maat_decision:, user_id:)
        end
      end
    end

    private

    def link_and_sync(decision)
      if application_type == Types::ApplicationType['change_in_financial_circumstances']
        decision.link_to_cifc(application_id:, user_id:)
      else
        decision.link(application_id:, user_id:)
      end
    end
  end
end
