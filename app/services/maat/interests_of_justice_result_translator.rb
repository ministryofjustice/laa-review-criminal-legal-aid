module Maat
  class InterestsOfJusticeResultTranslator < BaseTranslator
    def translate
      return nil if original.blank?

      Types::TestResult[means_result]
    end

    private

    def means_result
      case original
      when /PASS/
        'passed'
      when /FAIL/
        'failed'
      end
    end
  end
end
