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
        'pass'
      when /FULL/
        'contribution'
      when /FAIL|INEL/
        'fail'
      end
    end
  end
end
