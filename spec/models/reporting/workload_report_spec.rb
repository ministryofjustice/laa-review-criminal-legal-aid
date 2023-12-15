require 'rails_helper'

RSpec.describe Reporting::WorkloadReport do
  subject(:report) { described_class.new(observed_at:) }

  let(:observed_at) { Date.parse('2023-01-02').in_time_zone('London').end_of_day }

  describe '#rows' do
    subject(:rows) { report.rows }

    it 'returns a row for each work stream by default' do
      expect(rows.size).to eq(3)
      expect(rows.map(&:work_stream)).to contain_exactly(
        'criminal_applications_team', 'criminal_applications_team_2', 'extradition'
      )
    end
  end

  describe '#business_days' do
    it 'returns an array of the business days included in the report' do
      expect(report.business_days).to eq(
        %w[2023-01-03 2022-12-30 2022-12-29 2022-12-28 2022-12-23 2022-12-22 2022-12-21 2022-12-20 2022-12-19
           2022-12-16]
      )
    end
  end
end
