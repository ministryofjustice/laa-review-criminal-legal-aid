module Maat
  class MeansResultTranslator
    def initialize(maat_decision:)
      @maat_decision = maat_decision
    end

    def translate
      return nil unless means_result

      Types::TestResult[means_result]
    end

    class << self
      def translate(maat_decision:)
        new(maat_decision:).translate
      end
    end

    private

    attr_reader :maat_decision

    def means_result
      case maat_decision.means_result
      when /PASS/
        'passed'
      when /FAIL/
        crown_court_trial? ? 'passed_with_contribution' : 'failed'
      when /INEL/
        'failed'
      end
    end

    def crown_court_trial?
      assessment_rules == Types::AssessmentRules['crown_court']
    end

    def assessment_rules
      AssessmentRulesTranslator.new(maat_decision:).translate
    end
  end
end
