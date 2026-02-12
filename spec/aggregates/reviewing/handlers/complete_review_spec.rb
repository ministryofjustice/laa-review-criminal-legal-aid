require 'rails_helper'

RSpec.describe Reviewing::Handlers::CompleteReview do
  subject(:handler) { described_class.new }

  include_context 'with review'
  include_context 'with stubbed assignment'

  let(:event) { Reviewing::Completed.new(data: event_data) }
  let(:event_data) { { application_id: } }
  let(:decisions) { [] }
  let(:update_request) do
    instance_double(DatastoreApi::Requests::UpdateApplication, call: api_response)
  end
  let(:api_response) { { 'status' => 'completed' } }

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .with(
        application_id: application_id,
        payload: { decisions: },
        member: :complete
      )
      .and_return(update_request)
  end

  describe '#call' do
    context 'when event has no application_id' do
      let(:event_data) { {} }

      it 'returns without processing' do
        handler.call(event)

        expect(DatastoreApi::Requests::UpdateApplication).not_to have_received(:new)
      end
    end

    context 'when there are no draft decisions' do
      let(:decisions) { [] }

      it 'calls the Datastore API with empty decisions array' do
        handler.call(event)

        expect(update_request).to have_received(:call)
      end
    end

    context 'when there is a draft decision' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:decision_id) { SecureRandom.uuid }
      let(:user_id) { SecureRandom.uuid }
      let(:reference) { 123_456 }
      let(:decisions) do
        [
          Decisions::Draft.new(
            reference: reference,
            maat_id: nil,
            case_id: nil,
            interests_of_justice: nil,
            means: nil,
            funding_decision: 'refused',
            comment: nil,
            decision_id: decision_id,
            application_id: application_id,
            assessment_rules: 'non_means',
            overall_result: 'refused'
          ).as_json
        ]
      end

      before do
        args = {
          application_id:,
          user_id:,
          reference:, decision_id:
        }

        Reviewing::AddDecision.call(**args)
        Deciding::CreateDraft.call(**args)
        Deciding::SetFundingDecision.call(**args, funding_decision: 'refused')
      end

      it 'calls the Datastore API with the draft decision' do
        handler.call(event)

        expect(update_request).to have_received(:call)
      end
    end

    context 'when the Datastore API raises a ConflictError' do
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

    context 'when both ConflictError and ApiError could occur' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:conflict_error) { DatastoreApi::Errors::ConflictError.new('Conflict') }
      let(:api_error) { DatastoreApi::Errors::ApiError.new('Server error') }

      before do
        allow(Rails.error).to receive(:report)
      end

      context 'when ApiError occurs then ConflictError' do # rubocop:disable RSpec/MultipleMemoizedHelpers
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
