require 'rails_helper'

RSpec.describe Reporting::CurrentWorkloadReport do
  include_context 'with many other reviews'

  describe '#rows' do
    subject(:rows) { described_class.new(**arguments).rows }

    let(:arguments) { {} }

    before do
      travel_to Time.zone.local(2023, 11, 28, 12)

      insert_review_events([
                             { business_day: '2023-11-14', work_stream: 'extradition' },
                             { business_day: '2023-11-15' },
                             { business_day: '2023-11-15', work_stream: 'extradition' },
                             { business_day: '2023-11-23' },
                             { business_day: '2023-11-27' },
                             { business_day: '2023-11-27', state: 'sent_back' },
                             { business_day: '2023-11-27', state: 'completed' },
                             { business_day: '2023-11-28' }
                           ])
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
