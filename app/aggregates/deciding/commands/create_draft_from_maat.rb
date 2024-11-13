module Deciding
  class CreateDraftFromMaat < Command
    attribute :application_id, Types::Uuid
    attribute :application_type, Types::ApplicationType
    attribute :maat_decision, Maat::Decision
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        if decision.state.nil?
          decision.create_draft_from_maat(
            application_id:, maat_decision:, user_id:, application_type:
          )
        else
          if cifc?
            decision.link_to_cifc(application_id:, user_id:)
          else
            decision.link(application_id:, user_id:)
          end

          decision.sync_with_maat(maat_decision:, user_id:) if maat_decision&.checksum != decision.checksum
        end
      end
    end

    private

    def cifc?
      application_type == Types::ApplicationType['change_in_financial_circumstances']
    end
  end
end
