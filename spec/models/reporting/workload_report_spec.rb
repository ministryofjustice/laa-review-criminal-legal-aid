require 'rails_helper'

RSpec.describe Reporting::WorkloadReport do
  subject(:report) do
    described_class.new(observed_at:, age_limit:, number_of_rows:)
  end

  let(:observed_at) { Date.parse('2023-01-04').in_time_zone('London').end_of_day }
  let(:age_limit) { 2 }
  let(:number_of_rows) { 3 }

  describe '#rows' do
    subject(:rows) { report.rows }

    it 'returns an array of BusinessDayAgeRangeRow up to the configured age limit' do
      expect(rows.size).to eq(3)
      expect(rows).to all(be_a(Reporting::BusinessDayAgeRangeRow))
    end

    it 'each row contains data for a single business day' do
      allow(Reporting::BusinessDayAgeRangeRow).to receive(:new)
      rows
      [0..0, 1..1, 2..2].each do |age_range_in_business_days|
        expect(Reporting::BusinessDayAgeRangeRow).to have_received(:new).with(
          age_range_in_business_days:, observed_at:
        )
      end
    end

    context 'when the number_of_rows cannot accomodate 1 day per row' do
      let(:age_limit) { 9 }
      let(:number_of_rows) { 3 }

      it 'combines the remaining days into the final row' do
        allow(Reporting::BusinessDayAgeRangeRow).to receive(:new)
        rows

        [0..0, 1..1, 2..9].each do |age_range_in_business_days|
          expect(Reporting::BusinessDayAgeRangeRow).to have_received(:new).with(
            age_range_in_business_days:, observed_at:
          )
        end
      end

      it 'labels the rows accordingly' do
        expected_rows = ['0 days', '1 day', 'Between 2 and 9 days']
        expect(rows.map(&:label)).to eq(expected_rows)
      end
    end
  end

  it 'the age limit defaults to 9 days old' do
    expect(described_class.new.rows.last.label).to eq 'Between 4 and 9 days'
  end

  it 'the "number_of_rows" defaults to the number required to reach the age limit' do
    report = described_class.new(age_limit: 11, number_of_rows: nil)
    expect(report.rows.size).to eq 12
    expect(report.rows.last.label).to eq '11 days'
  end
end
