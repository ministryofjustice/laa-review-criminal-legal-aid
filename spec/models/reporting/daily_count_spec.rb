require 'rails_helper'

RSpec.describe Reporting::DailyCount do
  subject(:report) { described_class.new(filter:) }

  let(:filter) { ApplicationSearchFilter.new(assigned_status: SecureRandom.uuid) }

  describe '#counts' do
    subject(:counts) { report.counts }

    it 'default to four counts' do
      expect(report.counts.size).to be 4
    end
  end

  #
  # TODO:
  # It is likely that the way these counts are dirived will change.
  # For now, confirm that the expected searches are made.
  #
  describe '#filters' do
    subject(:filters) do
      described_class.new(filter: filter, rows: 2, today: Date.parse('2023-02-06')).filters
    end

    it 'includes non-date params from the origional filter' do
      expect(filters.map(&:assigned_status).uniq).to eq([filter.assigned_status])
    end

    describe 'day zero filter' do
      subject(:day_zero_filter) { filters.first }

      it 'has the correct date range' do
        expect(day_zero_filter.submitted_after.to_s).to eq('2023-02-06')
        expect(day_zero_filter.submitted_before.to_s).to eq('2023-02-07')
      end
    end

    describe 'last day filter' do
      subject(:last_day_filter) { filters.last }

      it 'includes all records up to and including the day' do
        expect(last_day_filter.submitted_before.to_s).to eq('2023-02-06')
        expect(last_day_filter.submitted_after).to be_nil
      end
    end
  end
end
