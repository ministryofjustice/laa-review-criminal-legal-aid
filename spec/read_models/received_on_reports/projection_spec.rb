require 'rails_helper'

RSpec.describe ReceivedOnReports::Projection do
  # rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/IndexedLet
  let(:event_store) { Rails.configuration.event_store }

  describe 'instance' do
    let(:stream_name) { ['ReceivedOn$2023-277'] }
    let(:split_time) { Time.zone.local(2023, 10, 5, 1, 21) }
    let(:observed_at) { Time.current }
    let(:cat1) { Types::WorkStreamType['criminal_applications_team'] }
    let(:cat2) { Types::WorkStreamType['criminal_applications_team_2'] }
    let(:extradition) { Types::WorkStreamType['extradition'] }
    let(:initial) { Types::ApplicationType['initial'] }
    let(:pse) { Types::ApplicationType['post_submission_evidence'] }

    describe '#dataset' do
      subject(:dataset) { described_class.new(stream_name:, observed_at:).dataset }

      before do
        ReceivedOnReports::Configuration.new.call(event_store)
        # We use the "split_time" to test being able to observe the stream at a given time.
        travel_to split_time - 1.day

        a, b, c, d, = Array.new(4) { SecureRandom.uuid }

        # Receive four CAT 1 (including 1 PSE) and one extradition application
        receive_application(a, cat1, initial)
        receive_application(b, cat1, initial)
        receive_application(c, cat1, pse)
        receive_application(d, extradition, initial)

        event_store.publish(Reviewing::Completed.new(
                              data: { application_id: b }
                            ))

        travel_to split_time

        event_store.publish(Reviewing::SentBack.new(
                              data: { application_id: d }
                            ))

        event_store.publish(Reviewing::Completed.new(
                              data: { application_id: c }
                            ))

        # This application should not be included in the data
        receive_application(SecureRandom.uuid, cat1, initial)

        travel_back
      end

      let(:cat1_initial) { dataset.dig(cat1, initial) }
      let(:cat1_pse) { dataset.dig(cat1, pse) }
      let(:extradition_initial) { dataset.dig(extradition, initial) }
      let(:extradition_pse) { dataset.dig(extradition, pse) }

      describe 'cat1 workstream data' do
        it 'returns a tally of received applications by application type' do
          expect(cat1_initial.total_received).to be 2
          expect(cat1_pse.total_received).to be 1
        end

        it 'returns a tally of closed applications by application type' do
          expect(cat1_initial.total_closed).to be 1
          expect(cat1_pse.total_closed).to be 1
        end
      end

      describe 'extradition workstream data' do
        it 'returns a tally of received applications by application type' do
          expect(extradition_initial.total_received).to be 1
          expect(extradition_pse.total_received).to be 0
        end

        it 'returns a tally of closed applications by application type' do
          expect(extradition_initial.total_closed).to be 1
          expect(extradition_pse.total_closed).to be 0
        end
      end

      context 'when observing 1 second before an event' do
        let(:observed_at) { split_time.in_time_zone('London') - 1.second }

        it 'excludes the event from the tally' do
          expect(cat1_pse.total_closed).to be 0
          expect(extradition_initial.total_closed).to be 0
        end
      end

      context 'when observing at the time of an event' do
        let(:observed_at) { split_time.in_time_zone('London') }

        it 'includes the event in the tally' do
          expect(cat1_pse.total_closed).to be 1
          expect(extradition_initial.total_closed).to be 1
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
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/IndexedLet

  def receive_application(application_id, work_stream, application_type)
    submitted_at = Time.current

    Reviewing::ReceiveApplication.new(
      application_id:, submitted_at:, work_stream:, application_type:
    ).call
  end
end
