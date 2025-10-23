require 'rails_helper'

RSpec.describe Maat::AssessmentRulesTranslator do
  expected_translations = [
    { case_type: 'INDICTABLE' }, 'crown_court',
    { case_type: 'SUMMARY ONLY' }, 'magistrates_court',
    { case_type: 'COMMITTAL' }, 'committal_for_sentence',
    { case_type: 'APPEAL CC' }, 'appeal_to_crown_court',
    { case_type: 'CC ALREADY' }, 'crown_court',
    { case_type: 'EITHER WAY' }, 'magistrates_court',
    { case_type: 'EITHER WAY', cc_rep_decision: 'Granted' }, 'crown_court',
    { case_type: 'EITHER WAY', cc_rep_decision: 'nil' }, 'crown_court',
  ]

  it_behaves_like 'a MAAT decision value translator', expected_translations
end
