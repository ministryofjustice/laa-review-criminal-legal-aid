module Decisions
  class OverallResultForm
    include DecisionFormPersistance

    attribute :funding_decision, :string
    validates :funding_decision, inclusion: { in: :possible_decisions }

    def possible_decisions
      [Types::FundingDecisionResult['granted_on_ioj'], Types::FundingDecisionResult['fail_on_ioj']]
    end

    class << self
      def build(decision)
        new(
          application_id: decision.application_id,
          decision_id: decision.decision_id,
          funding_decision: decision.funding_decision
        )
      end
    end

    private

    def command_class
      Deciding::SetFundingDecision
    end
  end
end
