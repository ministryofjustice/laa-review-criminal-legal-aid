module Maat
  class FundingDecisionTranslator < BaseTranslator
    def translate
      return nil if funding_decision.blank?

      Types::FundingDecision[funding_decision]
    end

    private

    def funding_decision
      case original
      when /PASS|GRANTED|FULL/
        'granted'
      when /INEL|FAIL/
        'refused'
      end
    end
  end
end
