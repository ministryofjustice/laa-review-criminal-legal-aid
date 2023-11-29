require 'rails_helper'

RSpec.describe Reporting::CurrentWorkloadReport do
  describe 'rows' do
    subject(:rows) { described_class.new(**arguments).rows }

    let(:arguments) { {} }

    before do
      Review.insert_all([
                          { application_id: SecureRandom.uuid, business_day: '2023-11-27', work_stream: 'criminal_applications_team', state: 'open' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-27', work_stream: 'criminal_applications_team', state: 'sent_back' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-27', work_stream: 'criminal_applications_team', state: 'completed' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-28', work_stream: 'criminal_applications_team', state: 'open' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-23', work_stream: 'criminal_applications_team', state: 'open' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-15', work_stream: 'criminal_applications_team', state: 'open' },
                          { application_id: SecureRandom.uuid, business_day: '2023-11-15', work_stream: 'extradition', state: 'open' },

                        ])
    end

    it 'returns correct number of applications received' do
      expect(rows).to eq [{ total_received: 3 }]

      [{total_received: }, {}, {}]
    end

    context 'when querying by work stream' do
      let(:arguments) { { work_streams: ['extradition'] } }

      it 'only shows counts for extradition work stream' do
        expect(rows.last).to eq({ business_day: Date.new(2023, 11, 15), total_open: 1, total_received: 1})
      end
    end
  end
end
