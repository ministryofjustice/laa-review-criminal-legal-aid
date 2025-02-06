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
        means:, funding_decision:, decision_id:, assessment_rules:
      )
    end

    private

    attr_reader :maat_decision

    delegate :case_id, to: :maat_decision

    def maat_id
      maat_decision.maat_ref
    end
    alias decision_id maat_id

    def reference
      maat_decision.usn
    end

    def interests_of_justice
      InterestsOfJusticeTranslator.translate(maat_decision:)
    end

    def means
      MeansTranslator.translate(maat_decision:)
    end

    def assessment_rules
      AssessmentRulesTranslator.translate(maat_decision:)
    end

    # The MAAT API can return partially completed results. During reassessment,
    # the MAAT API maintains the previous funding decision until the means
    # assessment is completed. Therefore, funding decisions that exist without
    # a corresponding means result should be ignored.
    def funding_decision
      return if means.blank?

      if maat_decision.cc_rep_decision.present?
        CrownCourtDecisionTranslator.translate(maat_decision.cc_rep_decision)
      else
        FundingDecisionTranslator.translate(maat_decision.funding_decision)
      end
    end
  end
end
