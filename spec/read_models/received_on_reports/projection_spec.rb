require 'rails_helper'

RSpec.describe ReceivedOnReports::Projection do
  let(:event_store) { Rails.configuration.event_store }

  describe 'instance' do
    let(:stream_name) { ['ReceivedOn$2023-278'] }
    let(:split_time) { Time.zone.local(2023, 10, 5, 1, 21) }
    let(:observed_at) { Time.current }

    describe '#dataset' do
      subject(:dataset) { described_class.new(stream_name:, observed_at:).dataset }

      before do
        # We use the "split_time" to test being able to observe the stream at a given time.
        travel_to split_time - 1.day

        events = [
          Reviewing::ApplicationReceived.new,
          Reviewing::ApplicationReceived.new,
          Reviewing::SentBack.new,
          Reviewing::ApplicationReceived.new
        ]

        event_store.publish(events, stream_name:)

        travel_to split_time

        event_store.publish(Reviewing::SentBack.new, stream_name:)

        travel_back
      end

      it 'returns a tally of received applications' do
        expect(dataset.fetch(:total_received)).to be 3
      end

      it 'returns a tally of closed applications' do
        expect(dataset.fetch(:total_closed)).to be 2
      end

      context 'when observing 1 second before an event' do
        let(:observed_at) { split_time.in_time_zone('London') - 1.second }

        it 'excludes the event from the tally' do
          expect(dataset.fetch(:total_closed)).to be 1
        end
      end

      context 'when observing at the time of an event' do
        let(:observed_at) { split_time.in_time_zone('London') }

        it 'includes the event in the tally' do
          expect(dataset.fetch(:total_closed)).to be 2
        end
      end
    end
  end

  describe '.for_dates' do
    before do
      allow(described_class).to receive(:new)
      described_class.for_date(business_day)
    end

    context 'when for a single date' do
      let(:business_day) { Date.new(2023, 10, 5) }

      it 'initializes the projection with the stream name for the business day' do
        expect(described_class).to have_received(:new).with(
          stream_name: 'ReceivedOn$2023-278',
          observed_at: nil
        )
      end
    end
  end
end
