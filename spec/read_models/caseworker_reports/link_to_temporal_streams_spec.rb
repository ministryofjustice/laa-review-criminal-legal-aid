require 'rails_helper'

RSpec.describe CaseworkerReports::LinkToTemporalStreams do
  let(:event_store) { instance_double(RailsEventStore::Client) }
  let(:event) { Reviewing::Completed.new(metadata: { timestamp: }) }
  let(:timestamp) { Time.zone.local(2023, 8, 1, 22, 59) }

  describe '#call' do
    subject(:call) { described_class.new(event_store:).call(event) }

    before do
      allow(event_store).to receive(:link)
      call
    end

    it 'links to the monthly stream based on the year and month of the year' do
      stream_name = 'MonthlyCaseworker$2023-08'
      expect(event_store).to have_received(:link).with([event.event_id], stream_name:)
    end

    it 'links to the weekly stream based on year and week of the year' do
      stream_name = 'WeeklyCaseworker$2023-31'
      expect(event_store).to have_received(:link).with([event.event_id], stream_name:)
    end

    it 'links to the daily stream based on year and day of the year' do
      stream_name = 'DailyCaseworker$2023-213'
      expect(event_store).to have_received(:link).with([event.event_id], stream_name:)
    end

    context 'when the event timestamp in utc is a different day in TZ London' do
      let(:timestamp) { Time.zone.local(2023, 7, 31, 23) }

      it 'converts the utc timestamps to the London time zone before determining the day of the year' do
        stream_name = 'DailyCaseworker$2023-213'
        expect(event_store).to have_received(:link).with([event.event_id], stream_name:)
      end
    end

    context 'when week of the year is from the previous year' do
      # although the date is in 2023, the week year is still 2022
      let(:timestamp) { Time.zone.local(2023, 1) }

      it 'converts the utc timestamps to the London time zone before determining the day of the year' do
        stream_name = 'WeeklyCaseworker$2022-52'
        expect(event_store).to have_received(:link).with([event.event_id], stream_name:)
      end
    end
  end
end
