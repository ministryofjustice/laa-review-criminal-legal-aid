require 'rails_helper'

RSpec.describe Reporting::BusinessDayAgeRangeRow do
  subject(:row) do
    described_class.new(observed_at:, age_range_in_business_days:)
  end

  let(:observed_at) { Date.parse('2023-01-04').in_time_zone('London').end_of_day }
  let(:age_range_in_business_days) { 0..0 }

  describe '#label' do
    subject(:label) { row.label }

    context 'when age is zero business days' do
      it { is_expected.to eq '0 days' }
    end

    context 'when age is one business day' do
      let(:age_range_in_business_days) { 1..1 }

      it { is_expected.to eq '1 day' }
    end

    context 'when age is two business day' do
      let(:age_range_in_business_days) { 2..2 }

      it { is_expected.to eq '2 days' }
    end

    context 'when age range' do
      let(:age_range_in_business_days) { 2..5 }

      it { is_expected.to eq 'Between 2 and 5 days' }
    end
  end

  describe '#dataset' do
    let(:age_range_in_business_days) { 3..5 }
    let(:dataset) { { total_closed: 57, total_received: 199 } }

    before do
      # mock data for 23rd, 28th and 29th November
      [23, 28, 29].each do |day|
        projection = instance_double(
          ReceivedOnReports::Projection,
          dataset: { total_received: 100 + day, total_closed: 100 - day }
        )

        allow(ReceivedOnReports::Projection).to receive(:for_date)
          .with(Date.new(2022, 12, day), observed_at:) { projection }
      end
    end

    describe '#total_received' do
      subject(:total_received) { row.total_received }

      it 'adds up the total_received for each business day in the age range' do
        expect(row.total_received).to eq 123 + 128 + 129
      end
    end

    describe '#total_open' do
      subject(:total_open) { row.total_open }

      it 'adds up the total_open for each business day in the age range' do
        expect(row.total_open).to eq 380 - (77 + 72 + 71)
      end
    end
  end
end
