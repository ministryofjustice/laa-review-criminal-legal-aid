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
        means:, funding_decision:, decision_id:, court_type:
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
      MeansTranslator.translate(maat_decision, court_type:)
    end

    # infer the court type of the decision from the MAAT decision.
    def court_type
      if crown_court_decision
        Types::CourtType['crown']
      elsif maat_decision.funding_decision
        Types::CourtType['magistrates']
      end
    end

    def funding_decision
      case court_type
      when Types::CourtType['crown']
        crown_court_decision
      when Types::CourtType['magistrates']
        FundingDecisionTranslator.translate(maat_decision.funding_decision)
      end
    end

    delegate :case_id, to: :maat_decision

    def crown_court_decision
      CrownCourtDecisionTranslator.translate(maat_decision.cc_rep_decision)
    end

    attr_reader :maat_decision
  end
end
