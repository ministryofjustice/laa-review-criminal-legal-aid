require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Reviewing::Handlers::CompleteReview do
  subject(:handler) { described_class.new }

  let(:application_id) { SecureRandom.uuid }
  let(:event) { Reviewing::Completed.new(data: event_data) }
  let(:event_data) { { application_id: } }
  let(:review) { instance_double(Reviewing::Review, draft_decisions:) }
  let(:draft_decisions) { [] }
  let(:expected_decisions) { [] }
  let(:update_request) do
    instance_double(DatastoreApi::Requests::UpdateApplication, call: api_response)
  end
  let(:api_response) { { 'status' => 'completed' } }

  before do
    allow(Reviewing::LoadReview).to receive(:call)
      .with(application_id:)
      .and_return(review)

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .with(
        application_id: application_id,
        payload: { decisions: expected_decisions },
        member: :complete
      )
      .and_return(update_request)
  end

  describe '#call' do
    context 'when event has no application_id' do
      let(:event_data) { {} }

      it 'returns without processing' do
        handler.call(event)

        expect(Reviewing::LoadReview).not_to have_received(:call)
        expect(DatastoreApi::Requests::UpdateApplication).not_to have_received(:new)
      end
    end

    context 'when there are no draft decisions' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:draft_decisions) { [] }
      let(:expected_decisions) { [] }

      it 'calls the Datastore API with empty decisions array' do
        handler.call(event)

        expect(Reviewing::LoadReview).to have_received(:call).with(application_id:)
        expect(update_request).to have_received(:call)
      end
    end

    # rubocop:disable RSpec/IndexedLet
    context 'when there are draft decisions' do
      let(:draft_decision1) { instance_double(Deciding::Decision) }
      let(:draft_decision2) { instance_double(Deciding::Decision) }
      let(:draft_decisions) { [draft_decision1, draft_decision2] }

      let(:decision_data1) do
        {
          'reference' => 111_111,
          'funding_decision' => 'granted',
          'decision_id' => SecureRandom.uuid,
          'application_id' => application_id
        }
      end

      let(:decision_data2) do
        {
          'reference' => 222_222,
          'funding_decision' => 'refused',
          'decision_id' => SecureRandom.uuid,
          'application_id' => application_id
        }
      end

      let(:expected_decisions) { [decision_data1, decision_data2] }

      before do
        allow(Decisions::Draft).to receive(:build)
          .with(draft_decision1)
          .and_return(instance_double(Decisions::Draft, as_json: decision_data1))

        allow(Decisions::Draft).to receive(:build)
          .with(draft_decision2)
          .and_return(instance_double(Decisions::Draft, as_json: decision_data2))
      end

      it 'processes all draft decisions' do # rubocop:disable RSpec/MultipleExpectations
        handler.call(event)

        expect(Decisions::Draft).to have_received(:build).with(draft_decision1)
        expect(Decisions::Draft).to have_received(:build).with(draft_decision2)
        expect(update_request).to have_received(:call)
      end
    end
    # rubocop:enable RSpec/IndexedLet

    context 'when the Datastore API raises a ConflictError' do
      let(:draft_decisions) { [] }
      let(:expected_decisions) { [] }
      let(:conflict_error) { DatastoreApi::Errors::ConflictError.new('Already completed') }

      before do
        allow(update_request).to receive(:call).and_raise(conflict_error)
        allow(Rails.error).to receive(:report)
      end

      it 'does not retry the request and raises the error' do
        expect { handler.call(event) }.to raise_error(DatastoreApi::Errors::ConflictError)
        expect(update_request).to have_received(:call).once
      end
    end

    context 'when the Datastore API raises an ApiError' do
      let(:draft_decisions) { [] }
      let(:expected_decisions) { [] }
      let(:api_error) { DatastoreApi::Errors::ApiError.new('Server error') }

      before do
        allow(Rails.error).to receive(:report)
      end

      context 'when the error persists after 3 retries' do
        before do
          allow(update_request).to receive(:call).and_raise(api_error)
        end

        it 'reports the error as not handled' do
          expect { handler.call(event) }.to raise_error(DatastoreApi::Errors::ApiError)

          expect(Rails.error).to have_received(:report)
            .with(api_error, handled: false, severity: :error)
            .exactly(3).times
        end

        it 'retries 3 times' do
          expect { handler.call(event) }.to raise_error(DatastoreApi::Errors::ApiError)

          expect(update_request).to have_received(:call).exactly(3).times
        end

        it 'raises the error after retries are exhausted' do
          expect { handler.call(event) }.to raise_error(DatastoreApi::Errors::ApiError)
        end
      end

      context 'when the error succeeds on retry' do
        before do
          call_count = 0
          allow(update_request).to receive(:call) do
            call_count += 1
            raise api_error if call_count == 1

            api_response
          end
        end

        it 'reports the error once' do
          handler.call(event)

          expect(Rails.error).to have_received(:report)
            .with(api_error, handled: false, severity: :error)
            .once
        end

        it 'retries and succeeds' do
          handler.call(event)

          expect(update_request).to have_received(:call).twice
        end
      end

      context 'when the error succeeds on second retry' do
        before do
          call_count = 0
          allow(update_request).to receive(:call) do
            call_count += 1
            raise api_error if call_count <= 2

            api_response
          end
        end

        it 'reports the error twice' do
          handler.call(event)

          expect(Rails.error).to have_received(:report)
            .with(api_error, handled: false, severity: :error)
            .twice
        end

        it 'retries twice and succeeds on third attempt' do
          handler.call(event)

          expect(update_request).to have_received(:call).exactly(3).times
        end
      end
    end

    context 'when both ConflictError and ApiError could occur' do
      let(:draft_decisions) { [] }
      let(:expected_decisions) { [] }
      let(:conflict_error) { DatastoreApi::Errors::ConflictError.new('Conflict') }
      let(:api_error) { DatastoreApi::Errors::ApiError.new('Server error') }

      before do
        allow(Rails.error).to receive(:report)
      end

      context 'when ApiError occurs then ConflictError' do
        before do
          call_count = 0
          allow(update_request).to receive(:call) do
            call_count += 1
            raise api_error if call_count == 1

            raise conflict_error
          end
        end

        it 'retries after ApiError but stops after ConflictError' do # rubocop:disable RSpec/MultipleExpectations
          expect { handler.call(event) }.to raise_error(DatastoreApi::Errors::ConflictError)

          expect(update_request).to have_received(:call).twice
          expect(Rails.error).to have_received(:report)
            .with(api_error, handled: false, severity: :error)
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
