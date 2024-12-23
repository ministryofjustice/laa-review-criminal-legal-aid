require 'rails_helper'

RSpec.describe Maat::FundingDecisionTranslator do
  expected_translations = %w[
    PASS granted
    FAIL refused
    INEL refused
    FULL granted
    GRANTED granted
    FAILMEANS refused
    FAILIOJ refused
    FAILMEIOJ refused
  ]

  it_behaves_like 'a MAAT value translator', expected_translations
end
