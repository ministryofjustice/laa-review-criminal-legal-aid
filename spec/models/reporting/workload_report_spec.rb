require 'rails_helper'

RSpec.describe Reporting::WorkloadReport do
  subject(:report) { described_class.new(observed_at:) }

  let(:observed_at) { Date.parse('2023-01-02').in_time_zone('London').end_of_day }

  describe '#rows' do
    describe 'CAT 1 rows' do
      let(:rows) { report.rows.first }

      it 'returns expected rows' do
        expect(rows.map(&:work_stream)).to all eq(WorkStream.new('criminal_applications_team'))

        expect(rows.map(&:application_type)).to contain_exactly('initial', 'post_submission_evidence',
                                                                'change_in_financial_circumstances')
      end
    end

    describe 'CAT 2 rows' do
      let(:rows) { report.rows.second }

      it 'returns expected rows' do
        expect(rows.map(&:work_stream)).to all eq(WorkStream.new('criminal_applications_team_2'))

        expect(rows.map(&:application_type)).to contain_exactly('initial', 'post_submission_evidence',
                                                                'change_in_financial_circumstances')
      end
    end

    describe 'Extradition rows' do
      let(:rows) { report.rows.third }

      it 'returns expected rows' do
        expect(rows.map(&:work_stream)).to all eq(WorkStream.new('extradition'))

        expect(rows.map(&:application_type)).to contain_exactly('initial', 'post_submission_evidence',
                                                                'change_in_financial_circumstances')
      end
    end

    describe 'Non-means rows' do
      let(:rows) { report.rows.last }

      it 'returns expected rows' do
        expect(rows.map(&:work_stream)).to all eq(WorkStream.new('non_means_tested'))

        expect(rows.map(&:application_type)).to contain_exactly('initial', 'post_submission_evidence',
                                                                'change_in_financial_circumstances')
      end
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
