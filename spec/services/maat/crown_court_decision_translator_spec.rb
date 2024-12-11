require 'rails_helper'

RSpec.describe Maat::CrownCourtDecisionTranslator do
  expected_translations = [
    'Granted - Passed Means Test', 'grant',
    'Granted - Failed Means Test', 'grant',
    'Refused - Ineligible', 'refuse',
    'Failed - CfS Failed Means Test', 'refuse'
  ].freeze

  it_behaves_like 'a MAAT value translator', expected_translations
end
