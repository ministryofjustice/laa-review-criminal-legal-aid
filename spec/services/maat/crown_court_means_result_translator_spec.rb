require 'rails_helper'

RSpec.describe Maat::CrownCourtMeansResultTranslator do
  expected_translations = [
    'INEL', 'failed',
    'HARDSHIP APPLICATION', nil,
    'FULL', nil,
    'PASS', 'passed',
    'FAIL', 'passed_with_contribution'
  ]

  it_behaves_like 'a MAAT value translator', expected_translations
end
