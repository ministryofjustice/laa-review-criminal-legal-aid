module Maat
  class CrownCourtDecisionTranslator < BaseTranslator
    def translate
      return nil if funding_decision.blank?

      Types::FundingDecision[funding_decision]
    end

    private

    def funding_decision
      case original
      when /Granted/
        'grant'
      when /Refused|Failed/
        'refuse'
      end
    end
  end
end
