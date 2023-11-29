require 'rails_helper'

RSpec.describe Reporting::CurrentWorkloadReport do
  describe 'rows' do
    subject(:rows) { described_class.new(**arguments).rows }

    let(:arguments) { {} }

    before do
      travel_to Time.zone.local(2023, 11, 28, 12)

      # rubocop:disable Rails/SkipsModelValidations
      Review.insert_all([
                          { application_id: SecureRandom.uuid, business_day: '2023-11-27',
work_stream: 'criminal_applications_team', state: 'open' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-27',
work_stream: 'criminal_applications_team', state: 'sent_back' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-27',
work_stream: 'criminal_applications_team', state: 'completed' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-28',
work_stream: 'criminal_applications_team', state: 'open' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-23',
work_stream: 'criminal_applications_team', state: 'open' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-15',
work_stream: 'criminal_applications_team', state: 'open' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-15', work_stream: 'extradition',
state: 'open' },

                        ])
      # rubocop:enable Rails/SkipsModelValidations
    end

    it 'returns the correct data for applications received' do
      expect(rows.map(&:total_received)).to eq [1, 3, 0, 1, 0, 0, 0, 0, 0, 2]
    end

    it 'returns the correct data for total open applications' do
      expect(rows.map(&:total_open)).to eq [1, 1, 0, 1, 0, 0, 0, 0, 0, 2]
    end

    context 'when querying by work stream' do
      let(:arguments) { { work_streams: ['extradition'] } }

      it 'only shows counts for extradition work stream' do
        expect(rows.map(&:total_received)).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
        expect(rows.map(&:total_open)).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
      end
    end
  end
end
