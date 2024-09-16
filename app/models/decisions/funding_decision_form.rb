module Decisions
  class FundingDecisionForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Dirty

    attribute :application_id, :immutable_string
    attribute :decision_id, :immutable_string

    attribute :result, :string
    attribute :details, :string

    validates :result, inclusion: { in: :possible_results  }

    def possible_results
      Types::FundingDecisionResult.values
    end

    def update_with_user!(attributes, user_id)
      assign_attributes(attributes) 
      validate!
      return unless changed?

      Deciding::SetFundingDecision.new(
        decision_id:, user_id:, result:, details:
      ).call
    end

    class << self
      def build(decision)
        new(
          application_id: decision.application_id,
          decision_id: decision.decision_id,
          result: decision.result,
          details: decision.details
        )
      end
    end
  end
end
