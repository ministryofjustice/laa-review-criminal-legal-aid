module Deciding
  class Unlink < Command
    attribute :application_id, Types::Uuid
    attribute :decision_id, Types::DecisionId
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        ActiveRecord::Base.transaction do
          decision.unlink(application_id:, user_id:)
          Reviewing::RemoveDecision.call(decision_id:, application_id:, user_id:)
        end
      end
    end
  end
end
