module Deciding
  class SetFundingDecision < Command
    attribute :user_id, Types::Uuid
    attribute :result, Types::FundingDecisionResult
    attribute :details, Types::String

    def call
      with_decision do |decision|
        decision.set_funding_decision(user_id:, result:, details:)
      end
    end
  end
end
