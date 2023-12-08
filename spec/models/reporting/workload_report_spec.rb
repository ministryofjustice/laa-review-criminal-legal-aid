require 'rails_helper'

RSpec.describe Reporting::WorkloadReport do
  subject(:report) do
    described_class.new(observed_at:)
  end

  let(:observed_at) { Date.parse('2023-01-04').in_time_zone('London').end_of_day }

  describe '#rows' do
    subject(:rows) { report.rows }

    it 'returns a row for each work stream by default' do
      expect(rows.size).to eq(3)
      expect(rows.map(&:work_stream)).to contain_exactly(
        'criminal_applications_team', 'criminal_applications_team_2', 'extradition'
      )
    end
  end
end
