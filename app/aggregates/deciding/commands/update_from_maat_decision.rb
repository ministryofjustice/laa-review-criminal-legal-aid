module Deciding
  class UpdateFromMaatDecision < Command
    attribute :maat_decision, Maat::Decision
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        decision.sync_with_maat(maat_decision:, user_id:)
      end
    end
  end
end

# #Add remove and change links which take you to the decsion and maat decision controllers.
#
# Add a funding decision you have entered from MAAT
# Start
#
# Check for synched?
#
# You will need to manually
# Start
#
