module Reviewing
  class AddMaatDecision < Command
    attribute :maat_id, Types::Integer
    attribute :decision_id, Types::Uuid

    def call
      with_review do |review|
        review.add_maat_decision(decision_id:, maat_id:)
      end
    end
  end
end
