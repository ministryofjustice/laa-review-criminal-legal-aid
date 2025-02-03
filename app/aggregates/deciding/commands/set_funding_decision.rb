module Deciding
  class SetFundingDecision < Command
    attribute :user_id, Types::Uuid
    attribute :funding_decision, Types::FundingDecision

    def call
      with_decision do |decision|
        decision.set_funding_decision(user_id:, funding_decision:)
      end
    end
  end
end
