require 'rails_helper'

RSpec.describe ReceivedOnReports::Configuration do
  let(:application_id) { SecureRandom.uuid }
  let(:event_store) { Rails.configuration.event_store }
  let(:submitted_at) { Time.zone.local(2023, 7, 30) }

  describe '#configuration' do
    before do
      user_id = SecureRandom.uuid
      # subscribe the handler to the event store
      described_class.new.call(event_store)

      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new) {
        instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
      }

      travel_to submitted_at

      Reviewing::ReceiveApplication.call(
        application_id: application_id, submitted_at: submitted_at.to_s, work_stream: 'extradition'
      )

      travel_to submitted_at + 3.days

      Reviewing::Complete.call(application_id:, user_id:)
    end

    it 'links events to the business day the application was first recived on' do
      reviewed_on_events = event_store.read.stream('ReceivedOn$2023-212').to_a
      review_events = event_store.read.stream("Reviewing$#{application_id}").to_a

      expect(reviewed_on_events).to eq(review_events)
      expect(reviewed_on_events.size).to eq(2)
    end
  end
end
