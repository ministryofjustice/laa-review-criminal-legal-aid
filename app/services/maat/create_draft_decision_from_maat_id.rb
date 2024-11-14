module Maat
  class CreateDraftDecisionFromMaatId
    include MaatIdServiceObject

    def call
      raise Deciding::ReferenceMismatch if reference_mismatch?

      ActiveRecord::Base.transaction do
        Reviewing::AddDecision.call(
          application_id:, user_id:, decision_id:
        )

        Deciding::CreateDraftFromMaat.call(
          application_id:, user_id:, decision_id:, maat_decision:, application_type:
        )
      end

      maat_decision
    end

    private

    def reference_mismatch?
      return false if cifc?
      return false if maat_decision.reference.blank?

      maat_decision.reference != reference
    end
  end
end
