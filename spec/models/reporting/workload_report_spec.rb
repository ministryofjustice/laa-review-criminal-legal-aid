require 'rails_helper'

RSpec.describe Reporting::WorkloadReport do
  subject(:report) { described_class.new day_zero: }

  let(:day_zero) { Date.parse('2023-01-04') }

  before do
    received_on_reports = [
      ['2023-01-05', 100, 0],
      ['2023-01-04', 10, 5],
      ['2023-01-03', 8, 8],
      ['2022-12-30', 5, 1],
      ['2022-12-29', 4, 3],
      ['2022-12-18', 50, 49],
      ['2022-12-17', 1000, 999],
      ['2022-12-16', 10_000, 1]
    ].map do |business_day, total_received, total_closed|
      { business_day:, total_received:, total_closed: }
    end

    # rubocop:disable Rails/SkipsModelValidations
    Reporting::ReceivedOnReport.insert_all(received_on_reports)
    # rubocop:enable Rails/SkipsModelValidations
  end

  describe '#table' do
    it 'returns a table of report data' do
      expect(report.table).to be_a Reporting::Table
    end

    it 'has column headers' do
      expect(report.table.headers.map(&:content)).to eq(
        ['Business days since applications were received', 'Applications received', 'Applications still open']
      )
    end

    it 'all but the first column\'s header are numeric' do
      expect(report.table.headers.map(&:numeric)).to eq(
        [false, true, true]
      )
    end

    it 'includes 4 rows of data' do
      expect(report.table.rows.size).to eq(4)
    end

    it 'row headers with "0 days", "1 day", "2 days", and "Between 3 and 9 days"' do
      expect(report.table.rows.map(&:first).map(&:content)).to eq(
        ['0 days', '1 day', '2 days', 'Between 3 and 9 days']
      )
    end

    describe 'data' do
      subject(:columns) { report.table.rows.map { |r| r[1, 2] }.transpose }

      describe 'received applications' do
        subject(:received_counts) { columns.first.map(&:content) }

        it { is_expected.to eq([10, 8, 5, 1054]) }
      end

      describe 'open applications' do
        subject(:open_counts) { columns.last.map(&:content) }

        it { is_expected.to eq([5, 0, 4, 3]) }
      end
    end
  end

  describe 'number of rows can be configured using :number_of_days' do
    subject(:report) { described_class.new(number_of_rows: 7) }

    it 'returns the counts for the four working days up to and including day_zero' do
      expect(report.table.rows.size).to be 7
    end
  end
end
