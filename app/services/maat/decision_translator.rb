module Maat
  class DecisionTranslator
    def initialize(maat_decision:)
      @maat_decision = maat_decision
    end

    class << self
      def translate(maat_decision)
        new(maat_decision:).translate
      end
    end

    def translate
      Decisions::Draft.new(
        maat_id:, case_id:, reference:, interests_of_justice:,
        means:, funding_decision:, decision_id:
      )
    end

    private

    def maat_id
      maat_decision.maat_ref
    end
    alias decision_id maat_id

    def reference
      maat_decision.usn
    end

    def interests_of_justice
      InterestsOfJusticeTranslator.translate(maat_decision)
    end

    def means
      MeansTranslator.translate(maat_decision)
    end

    def funding_decision
      return crown_court_decision if crown_court_decision
      return nil unless maat_decision.funding_decision

      FundingDecisionTranslator.translate(maat_decision.funding_decision)
    end

    delegate :case_id, to: :maat_decision

    def crown_court_decision
      CrownCourtDecisionTranslator.translate(maat_decision.cc_rep_decision)
    end

    attr_reader :maat_decision
  end
end
