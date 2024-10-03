module Deciding
  class UpdateFromLinkedDecision < Command
    def call
      with_decision do |decision|
        return unless decision.maat_id

        maat_decision = Maat::GetDecision.new.by_maat_id(
          decision.maat_id
        )

        decision.sync_with_maat(maat_decision: maat_decision.to_hash) if maat_decision&.checksum != decision.checksum
      end
    end
  end
end
