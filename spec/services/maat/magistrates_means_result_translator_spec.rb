require 'rails_helper'

RSpec.describe Maat::MagistratesMeansResultTranslator do
  expected_translations = [
    'INEL', nil,
    'HARDSHIP APPLICATION', nil,
    'FULL', nil,
    'PASS', 'passed',
    'FAIL', 'failed'
  ]

  it_behaves_like 'a MAAT value translator', expected_translations
end
