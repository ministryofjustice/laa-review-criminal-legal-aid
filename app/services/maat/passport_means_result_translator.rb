module Maat
  class PassportMeansResultTranslator < BaseTranslator
    def translate
      return nil unless means_result

      Types::TestResult[means_result]
    end

    private

    def means_result
      case original
      when /PASS/
        'passed'
      end
    end
  end
end
