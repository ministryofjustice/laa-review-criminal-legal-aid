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
