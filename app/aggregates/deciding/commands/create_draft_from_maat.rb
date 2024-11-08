module Deciding
  class CreateDraftFromMaat < Command
    attribute :application_id, Types::Uuid
    attribute :maat_decision, Maat::Decision
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        raise AlreadyCreated if decision.application_id.present? 

        if decision.state.nil?
          decision.create_draft_from_maat(
            application_id:, maat_decision:, user_id:
          )
        else
          decision.link(application_id:, user_id:)

          if maat_decision&.checksum != decision.checksum
            decision.sync_with_maat(maat_decision:, user_id:)
          end
        end
      end
    end
  end
end

# is it okay to link based on what we've given???? 
# Should we do it by USN
#
