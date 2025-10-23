module Maat
  class AssessmentRulesTranslator
    def initialize(maat_decision:)
      @maat_decision = maat_decision
    end

    def translate
      return nil unless assessment_rules

      Types::AssessmentRules[assessment_rules]
    end

    class << self
      def translate(maat_decision:)
        new(maat_decision:).translate
      end
    end

    private

    attr_reader :maat_decision

    def assessment_rules
      case maat_decision.case_type
      when 'APPEAL CC'
        'appeal_to_crown_court'
      when 'COMMITTAL'
        'committal_for_sentence'
      when 'EITHER WAY'
        infer_either_way_assessment_rules
      when 'INDICTABLE', 'CC ALREADY'
        'crown_court'
      when 'SUMMARY ONLY'
        'magistrates_court'
      end
    end

    def infer_either_way_assessment_rules
      maat_decision.cc_rep_decision ? 'crown_court' : 'magistrates_court'
    end
  end
end
