require 'rails_helper'

RSpec.describe Maat::CrownCourtDecisionTranslator do
  expected_translations = [
    'Granted - Passed Means Test', 'granted',
    'Granted - Failed Means Test', 'granted',
    'Refused - Ineligible', 'refused',
    'Failed - CfS Failed Means Test', 'refused'
  ].freeze

  it_behaves_like 'a MAAT value translator', expected_translations
end
