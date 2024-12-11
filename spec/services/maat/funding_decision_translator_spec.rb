require 'rails_helper'

RSpec.describe Maat::FundingDecisionTranslator do
  expected_translations = %w[
    PASS grant
    FAIL refuse
    INEL refuse
    FULL grant
    GRANTED grant
    FAILMEANS refuse
    FAILIOJ refuse
    FAILMEIOJ refuse
  ]

  it_behaves_like 'a MAAT value translator', expected_translations
end
