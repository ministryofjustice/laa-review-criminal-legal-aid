require 'rails_helper'

describe Reporting::ProcessedReport do
  subject(:report) { described_class.new }

  describe '#rows' do
    subject(:rows) { report.rows }

    it 'all but the first column are numeric' do
      expect(rows.first.map(&:numeric)).to eq [false, true]
    end

    it 'includes 3 rows' do
      expect(rows.size).to eq(3)
    end

    it 'includes the row headers' do
      expect(rows.map(&:first).map(&:content)).to eq(['Today', 'Yesterday', 'Day before yesterday'])
    end

    describe 'data' do
      subject(:data) { rows.map(&:last).map(&:content) }

      before do
        event_store = Rails.configuration.event_store

        # Yesterday
        travel_to Time.zone.now.yesterday

        event_store.publish(Reviewing::Completed.new)

        # The day before yesterday
        travel_to Time.zone.now.yesterday

        event_store.publish(Reviewing::SentBack.new)

        # The day before, the day before yesterday
        travel_to Time.zone.now.yesterday

        event_store.publish(Reviewing::Completed.new)

        # Today
        travel_back

        event_store.publish(Reviewing::ApplicationReceived.new)
        event_store.publish(Reviewing::Completed.new)
        event_store.publish(Reviewing::SentBack.new)
      end

      it 'includes a count of completing events for each day' do
        expect(data).to eq([2, 1, 1])
      end
    end
  end
end
