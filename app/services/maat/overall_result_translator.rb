module Maat
  class OverallResultTranslator < BaseTranslator
    EFORMS_OVERALL_RESULT_TEXT = {
      'GRANTED' => 'Granted',
      'FAILMEANS' => 'Failed Means',
      'FAILIOJ' => 'Failed IoJ',
      'FAILMEIOJ' => 'Failed Means & IoJ'
    }.freeze

    def translate
      EFORMS_OVERALL_RESULT_TEXT.fetch(original, original)
    end
  end
end
