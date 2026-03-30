require 'rails_helper'

RSpec.describe Calendar do
  subject(:calendar) { described_class.new }

  let(:bank_holidays) do
    [Date.new(2026, 1, 1), Date.new(2026, 4, 3), Date.new(2026, 4, 6)]
  end

  before do
    allow(Govuk::BankHolidays).to receive(:call).and_return(bank_holidays)
  end

  it 'loads holidays from Govuk::BankHolidays' do
    expect(calendar.holidays).to eq bank_holidays
  end

  it 'treats a bank holiday as a non-working day' do
    expect(calendar.business_day?(Date.new(2026, 1, 1))).to be false
  end

  it 'treats a regular weekday as a working day' do
    expect(calendar.business_day?(Date.new(2026, 1, 5))).to be true
  end

  it 'treats a weekend day as a non-working day' do
    expect(calendar.business_day?(Date.new(2026, 1, 3))).to be false
  end

  context 'when Govuk::BankHolidays returns nil' do
    before do
      allow(Govuk::BankHolidays).to receive(:call).and_return(nil)
    end

    it 'initialises with an empty holidays list' do
      expect(calendar.holidays).to eq []
    end
  end
end
