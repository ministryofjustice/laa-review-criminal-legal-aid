require 'rails_helper'

RSpec.describe Maat::MeansResultTranslator do
  expected_translations = %w[
    PASS passed
    INEL failed
    FULL passed_with_contribution
    FAIL failed
  ]

  it_behaves_like 'a MAAT value translator', expected_translations
end
