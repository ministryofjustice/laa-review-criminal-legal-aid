module Deciding
  class UpdateFromMaatDecision < Command
    attribute :maat_decision, Decisions::Draft
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        raise MaatRecordNotChanged unless maat_decision.checksum != decision.checksum

        decision.sync_with_maat(maat_decision: maat_decision.to_h, user_id: user_id)
      end
    end
  end
end
