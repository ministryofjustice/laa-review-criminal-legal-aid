module Reviewing
  class AddMaatDecision < Command
    attribute :decision_id, Types::Uuid

    def call
      with_review do |review|
        review.add_maat_decision(decision_id:)
      end
    end
  end
end
