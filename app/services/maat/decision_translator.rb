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
        means:, funding_decision:, decision_id:, court_type:, overall_result:
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

    # The MAAT API can return partially completed results. During reassessment,
    # the MAAT API maintains the previous funding decision until the means
    # assessment is completed. Therefore, funding decisions that exist without
    # a corresponding means result should be ignored.
    def funding_decision
      return if means.blank?

      case court_type
      when Types::CourtType['crown']
        crown_court_decision
      when Types::CourtType['magistrates']
        FundingDecisionTranslator.translate(maat_decision.funding_decision)
      end
    end

    # Store the overall result in the format previously shown to eForms users.
    # Storing the string since rules as to what is shown are complex and vary
    # by court and case type.
    #
    # Note: The MAAT API returns a string for Crown Court decisions
    # but a constant for Magistrates' Court decisions.
    def overall_result
      return maat_decision.cc_rep_decision if court_type == Types::CourtType['crown']

      OverallResultTranslator.translate(maat_decision.funding_decision)
    end

    def crown_court_decision
      CrownCourtDecisionTranslator.translate(maat_decision.cc_rep_decision)
    end
  end
end
