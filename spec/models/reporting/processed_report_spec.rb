require 'rails_helper'

describe Reporting::ProcessedReport do
  subject(:report) { described_class.new }

  describe '#rows' do
    subject(:rows) { described_class.new(**arguments).rows }

    let(:arguments) { {} }

    before do
      travel_to Time.zone.local(2023, 11, 28, 12)

      # rubocop:disable Rails/SkipsModelValidations
      Review.insert_all([
                          { application_id: SecureRandom.uuid, reviewed_on: '2023-11-28',
                            work_stream: 'criminal_applications_team' },
                          { application_id: SecureRandom.uuid, reviewed_on: '2023-11-27',
                            work_stream: 'extradition' },
                          { application_id: SecureRandom.uuid, reviewed_on: '2023-11-27',
                            work_stream: 'criminal_applications_team' },
                          { application_id: SecureRandom.uuid, reviewed_on: '2023-11-27',
                            work_stream: 'criminal_applications_team' },
                          { application_id: SecureRandom.uuid, reviewed_on: '2023-11-26',
                            work_stream: 'criminal_applications_team' },
                          { application_id: SecureRandom.uuid, reviewed_on: '2023-11-25',
                            work_stream: 'criminal_applications_team' },
                        ])
      # rubocop:enable Rails/SkipsModelValidations
    end


    it 'includes 3 rows by default' do
      expect(rows.size).to eq(3)
    end

    describe 'data' do
      subject(:data) { rows.pluck(:total_processed) }

      it 'includes a count of completing events for each day' do
        expect(data).to eq([1, 3, 1])
      end

      context 'when querying by work stream' do
        let(:arguments) { { work_streams: ['extradition'] } }

        it 'only shows counts for extradition work stream' do
          expect(data).to eq([0, 1, 0])
        end
      end
    end
  end
end
