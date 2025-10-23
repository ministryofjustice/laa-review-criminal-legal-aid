require 'rails_helper'

RSpec.describe Maat::MeansResultTranslator do
  expected_translations = [
    { means_result: 'FAIL' }, 'failed',
    { means_result: 'FAIL', case_type: 'COMMITTAL' }, 'failed',
    { means_result: 'FAIL', case_type: 'APPEAL CC' }, 'failed',
    { means_result: 'FAIL', case_type: 'CC ALREADY' }, 'passed_with_contribution',
    { means_result: 'FAIL', case_type: 'INDICTABLE' }, 'passed_with_contribution',
    { means_result: 'FULL' }, nil,
    { means_result: 'HARDSHIP APPLICATION' }, nil,
    { means_result: 'INEL' }, 'failed',
    { means_result: 'INEL' }, 'failed',
    { means_result: 'PASS' }, 'passed',
  ]

  it_behaves_like 'a MAAT decision value translator', expected_translations
end
