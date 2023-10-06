require 'rails_helper'

RSpec.describe Reporting::BusinessDayAgeRangeRow do
  subject(:row) do
    described_class.new(observed_at:, age_range_in_business_days:)
  end

  let(:observed_at) { Date.parse('2023-01-04').in_time_zone('London').end_of_day }
  let(:age_range_in_business_days) { 0..0 }
  let(:dataset) { { total_closed: 57, total_received: 199 } }

  before do
    projection = instance_double(ReceivedOnReports::Projection, dataset:)
    allow(ReceivedOnReports::Projection).to receive(:for_dates) { projection }
  end

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

  describe '#total_received' do
    subject(:total_received) { row.total_received }

    it { is_expected.to be 199 }
  end

  describe '#total_open' do
    subject(:total_open) { row.total_open }

    it { is_expected.to be 142 }
  end
end
