module Decisions
  class OverallResultForm
    include DecisionFormPersistance

    attribute :funding_decision, :string
    validates :funding_decision, inclusion: { in: :possible_decisions }

    def possible_decisions
      [Types::FundingDecision['granted'], Types::FundingDecision['refused']]
    end

    class << self
      def build(application:, decision:)
        new(
          application: application,
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
