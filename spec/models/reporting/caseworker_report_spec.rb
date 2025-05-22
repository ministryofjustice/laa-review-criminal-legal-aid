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
      allow(CaseworkerReports::EventDataset).to receive(:new).and_return(dataset)
      report
    end

    it 'initializes the projection with the correct stream' do
      expect(CaseworkerReports::EventDataset).to have_received(:new).with(stream_name: 'WeeklyCaseworker$2023-41')
    end

    it 'initializes the class with the dataset' do
      expect(report.instance_variable_get(:@dataset)).to be dataset
    end
  end

  describe '#rows' do
    subject(:rows) { report.rows }

    let(:dataset) do
      instance_double(
        CaseworkerReports::EventDataset,
        basic_projection: {
          a: instance_double(CaseworkerReports::Row, user_name: 'Al Hart', total_assigned_to_user: 1),
          b: instance_double(CaseworkerReports::Row, user_name: 'Bo Brown', total_assigned_to_user: 0),
          c: instance_double(CaseworkerReports::Row, user_name: 'An Brown', total_assigned_to_user: 2)
        }
      )
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
          instance_double(
            CaseworkerReports::EventDataset,
            basic_projection: {
              a: instance_double(CaseworkerReports::Row, user_name: 'Al', percentage_closed_by_user: 0),
              b: instance_double(CaseworkerReports::Row, user_name: 'Bo', percentage_closed_by_user: 99),
              c: instance_double(CaseworkerReports::Row, user_name: 'Ad', percentage_closed_by_user: nil)
            }
          )
        end
        let(:sort_by) { 'percentage_closed_by_user' }

        it 'reverses the order' do
          expect(rows.map(&:user_name)).to eq(%w[Bo Al Ad])
        end
      end
    end
  end

  describe '#csv' do
    subject(:csv) { report.csv }

    let(:dataset) do
      instance_double(
        CaseworkerReports::EventDataset,
        work_queue_projection: {
          a: {
            'criminal_applications_team' =>
              instance_double(CaseworkerReports::Row,
                              user_name: 'Al Hart',
                              work_queue: 'criminal_applications_team',
                              assigned_to_user: 4,
                              reassigned_to_user: 0,
                              reassigned_from_user: 0,
                              unassigned_from_user: 0,
                              completed_by_user: 5,
                              sent_back_by_user: 1,
                              total_assigned_to_user: 4,
                              total_unassigned_from_user: 0,
                              total_closed_by_user: 6)
          },
          b: {
            'extradition' =>
              instance_double(CaseworkerReports::Row,
                              user_name: 'Bo Brown',
                              work_queue: 'extradition',
                              assigned_to_user: 7,
                              reassigned_to_user: 1,
                              reassigned_from_user: 0,
                              unassigned_from_user: 0,
                              completed_by_user: 7,
                              sent_back_by_user: 3,
                              total_assigned_to_user: 8,
                              total_unassigned_from_user: 0,
                              total_closed_by_user: 10)
          },
          c: {
            'non_means_tested' =>
              instance_double(CaseworkerReports::Row,
                              user_name: 'An Brown',
                              work_queue: 'non_means_tested',
                              assigned_to_user: 2,
                              reassigned_to_user: 1,
                              reassigned_from_user: 1,
                              unassigned_from_user: 0,
                              completed_by_user: 1,
                              sent_back_by_user: 1,
                              total_assigned_to_user: 3,
                              total_unassigned_from_user: 1,
                              total_closed_by_user: 2),
            'post_submission_evidence' =>
              instance_double(CaseworkerReports::Row,
                              user_name: 'An Brown',
                              work_queue: 'post_submission_evidence',
                              assigned_to_user: 5,
                              reassigned_to_user: 0,
                              reassigned_from_user: 2,
                              unassigned_from_user: 3,
                              completed_by_user: 8,
                              sent_back_by_user: 2,
                              total_assigned_to_user: 5,
                              total_unassigned_from_user: 5,
                              total_closed_by_user: 10)
          }
        }
      )
    end

    # rubocop:disable Layout/LineLength
    it 'has the correct data' do
      expect(csv).to eq(
        "user,work_queue,assigned_to_user,reassigned_to_user,reassigned_from_user,unassigned_from_user,completed_by_user,sent_back_by_user,total_assigned_to_user,total_unassigned_from_user,total_closed_by_user\n" \
        "Al Hart,criminal_applications_team,4,0,0,0,5,1,4,0,6\n" \
        "An Brown,non_means_tested,2,1,1,0,1,1,3,1,2\n" \
        "An Brown,post_submission_evidence,5,0,2,3,8,2,5,5,10\n" \
        "Bo Brown,extradition,7,1,0,0,7,3,8,0,10\n"
      )
    end
    # rubocop:enable Layout/LineLength
  end
end
