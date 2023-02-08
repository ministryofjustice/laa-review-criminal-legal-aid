require 'rails_helper'

RSpec.describe Reporting::DailyCount do
  # Required logic for business day counts for submissions:
  #
  # Example given for a week with a bank holiday Monday, viewed on Wednesdays.
  #
  #               | 29/12 | 30/12 | 31/01 | 1/1 | 2/1 | 3/1 | 4/1 |
  #               |  thu  |  fri  |  sat  | sun | mon | tue | wed |
  # age_in_days   |   3   |   2   |   1   |  1  |  1  |  1  |  0  |
  # after_date    |  thu  |  fri  |  sat  | sat | sat | sat | wed |
  # before_date   |  fri  |  sat  |  wed  | wed | wed | wed | nil |

  subject(:report) { described_class.new(filter:, day_zero:) }

  let(:filter) { ApplicationSearchFilter.new(assigned_status: SecureRandom.uuid) }
  let(:day_zero) { Date.parse('2023-01-04') }

  let(:expected_search_filter_periods) do
    [
      [Date.parse('2023-01-04'), Date.parse('2023-01-05')],
      [Date.parse('2022-12-31'), Date.parse('2023-01-04')],
      [Date.parse('2022-12-30'), Date.parse('2022-12-31')],
      [nil, Date.parse('2022-12-30')]
    ]
  end

  describe '#filters' do
    it 'includes non-date params from the origional filter' do
      expect(report.filters.map(&:assigned_status).uniq).to eq([filter.assigned_status])
    end

    it 'sets submitted_after and submitted_before according to the BusinessDay periods' do
      filtered_periods = report.filters.map { |f| [f.submitted_after, f.submitted_before] }

      expect(filtered_periods).to eq(expected_search_filter_periods)
    end
  end

  describe '#counts' do
    subject(:counts) { report.counts }

    before do
      allow(ApplicationSearch).to receive(:new) do
        instance_double(ApplicationSearch, total: 2)
      end
    end

    it 'returns the counts for the four working days up to and including day_zero' do
      expect(report.counts.size).to be 4
      expect(report.counts).to eq [2, 2, 2, 2]
    end

    describe 'number of counts can be configure using :number_of_days' do
      subject(:report) { described_class.new(filter: filter, number_of_days: 7) }

      it 'returns the counts for the four working days up to and including day_zero' do
        expect(report.counts.size).to be 7
      end
    end
  end
end
