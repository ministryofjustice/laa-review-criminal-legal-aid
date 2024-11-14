module Maat
  class UpdateDraftDecision
    include MaatIdServiceObject

    def call
      Deciding::UpdateFromMaatDecision.call(
        user_id:, decision_id:, maat_decision:
      )

      maat_decision
    end
  end
end
