require 'rails_helper'

RSpec.describe CaseworkerReports::Configuration do
  let(:event_store) { Rails.configuration.event_store }
  let(:event) { Reviewing::Completed.new }

  describe '#configuration' do
    before do
      described_class.new.call(event_store)

      travel_to Time.zone.local(2023, 8, 1, 0, 1)
      event_store.publish(event)
    end

    it 'links caseworker report events to monthly, weekly, and daily temporal streams' do
      ['MonthlyCaseworker$2023-08', 'WeeklyCaseworker$2023-31', 'DailyCaseworker$2023-213'].each do |stream_name|
        stream_events = event_store.read.stream(stream_name).to_a
        expect(stream_events.map(&:event_id)).to contain_exactly(event.event_id)
      end
    end
  end
end
