module Maat
  class MeansResultTranslator < BaseTranslator
    def translate
      return nil if original.blank?

      Types::TestResult[means_result]
    end

    private

    def means_result
      case original
      when /PASS/
        'passed'
      when /FULL/
        'passed_with_contribution'
      when /FAIL|INEL/
        'failed'
      end
    end
  end
end
