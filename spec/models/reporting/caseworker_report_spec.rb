require 'rails_helper'

describe Reporting::CaseworkerReport do
  let(:dataset) { {} }

  let(:report) do
    described_class.new(dataset:)
  end

  describe '.for_time_period' do
    let(:report) { described_class.for_time_period(time_period:) }

    let(:time_period) { Reporting::TimePeriod.new(interval: 'weekly', date: '2023-10-15') }

    before do
      allow(CaseworkerReports::Projection).to receive(:new) do
        instance_double(CaseworkerReports::Projection, dataset:)
      end
      report
    end

    it 'initializes the projection with the correct stream' do
      expect(CaseworkerReports::Projection).to have_received(:new).with(stream_name: 'WeeklyCaseworker$2023-41')
    end

    it 'initializes the class with the dataset' do
      expect(report.instance_variable_get(:@dataset)).to be dataset
    end
  end

  describe '#rows' do
    subject(:rows) { report.rows }

    let(:dataset) do
      {
        a: instance_double(CaseworkerReports::Row, user_name: 'Al Hart', total_assigned_to_user: 1),
        b: instance_double(CaseworkerReports::Row, user_name: 'Bo Brown', total_assigned_to_user: 0),
        c: instance_double(CaseworkerReports::Row, user_name: 'An Brown', total_assigned_to_user: 2)
      }
    end

    context 'with default sorting' do
      it 'defaults to sorting by user_name case insensitive' do
        expect(rows.map(&:user_name)).to eq(['Al Hart', 'An Brown', 'Bo Brown'])
      end
    end

    context 'when sorting is specified' do
      let(:report) do
        described_class.new(dataset: dataset, sorting: { sort_by:, sort_direction: })
      end

      let(:sort_by) { 'user_name' }
      let(:sort_direction) { 'descending' }

      context 'when sort direction is descending' do
        it 'reverses the order' do
          expect(rows.map(&:user_name)).to eq(['Bo Brown', 'An Brown', 'Al Hart'])
        end
      end

      context 'when sort_by is assigned_to_user' do
        let(:sort_by) { 'total_assigned_to_user' }

        it 'reverses the order' do
          expect(rows.map(&:user_name)).to eq(['An Brown', 'Al Hart', 'Bo Brown'])
        end
      end

      context 'when sorted values include nil' do
        let(:dataset) do
          {
            a: instance_double(CaseworkerReports::Row, user_name: 'Al', percentage_closed_by_user: 0),
            b: instance_double(CaseworkerReports::Row, user_name: 'Bo', percentage_closed_by_user: 99),
            c: instance_double(CaseworkerReports::Row, user_name: 'Ad', percentage_closed_by_user: nil)
          }
        end
        let(:sort_by) { 'percentage_closed_by_user' }

        it 'reverses the order' do
          expect(rows.map(&:user_name)).to eq(%w[Bo Al Ad])
        end
      end
    end
  end
end
