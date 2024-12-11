require 'rails_helper'

RSpec.describe Maat::MeansResultTranslator do
  expected_translations = %w[
    PASS pass
    INEL fail
    FULL contribution
    FAIL fail
  ]

  it_behaves_like 'a MAAT value translator', expected_translations
end
