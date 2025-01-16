module Maat
  class CrownCourtMeansResultTranslator < BaseTranslator
    def translate
      return nil unless means_result

      Types::TestResult[means_result]
    end

    private

    def means_result
      case original
      when /PASS/
        'passed'
      when /FAIL/
        'passed_with_contribution'
      when /INEL/
        'failed'
      end
    end
  end
end
