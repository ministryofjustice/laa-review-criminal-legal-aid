require 'rails_helper'

RSpec.describe Maat::OverallResultTranslator do
  expected_translations = [
    'GRANTED', 'Granted',
    'FAILMEANS', 'Failed Means',
    'FAILIOJ', 'Failed IoJ',
    'FAILMEIOJ', 'Failed Means & IoJ'
  ]

  it_behaves_like 'a MAAT value translator', expected_translations
end
