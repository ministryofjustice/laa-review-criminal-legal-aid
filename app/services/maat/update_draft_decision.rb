module Maat
  class UpdateDraftDecision
    def initialize(decision:, user_id:)
      @decision = decision
      @user_id = user_id
    end

    def call
      Deciding::UpdateFromMaatDecision.call(
        user_id:, decision_id:, maat_decision:
      )

      maat_decision
    end

    class << self
      def call(args)
        new(**args).call
      end
    end

    private

    attr_reader :decision, :user_id

    delegate :maat_id, :decision_id, to: :decision

    def maat_decision
      @maat_decision ||= Maat::GetDecision.new.by_maat_id(maat_id)
    end
  end
end
