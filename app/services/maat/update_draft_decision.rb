module Maat
  class UpdateDraftDecision
    def initialize(maat_id:, user_id:)
      @maat_id = maat_id
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

    attr_reader :maat_id, :user_id
    alias decision_id maat_id

    def maat_decision
      @decision ||= Maat::GetDecision.new.by_maat_id!(maat_id)

      return unless @decision

      Maat::DecisionTranslator.translate(@decision)
    end
  end
end
