require 'rails_helper'

RSpec.describe Reviewing::SendBack do
  subject(:command) do
    described_class.new(application_id:, user_id:, return_details:)
  end

  include_context 'with assignee'

  before do
    Reviewing::ReceiveApplication.call(
      application_id: application_id, submitted_at: 1.day.ago.to_s, work_stream: 'extradition',
      application_type: 'initial', reference: 345
    )

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).with(
      {
        application_id: application_id,
        payload: { return_details: },
        member: :return
      }
    ).and_return(return_request)
  end

  let(:return_request) do
    instance_double(
      DatastoreApi::Requests::UpdateApplication,
      call: JSON.parse(
        LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read
      )
    )
  end

  let(:user_id) { SecureRandom.uuid }

  let(:return_details) do
    { reason: 'evidence_issue', details: 'Detailed reason for return' }
  end

  include_context 'with review'

  context 'with a valid reason' do
    it 'changes the state from :received to :sent_back' do
      expect { command.call }.to change { review.state }
        .from(:open).to(:sent_back)
    end

    it 'records the return reason' do
      expect { command.call }.to change { review.return_reason }
        .from(nil).to('evidence_issue')
      expect(return_request).to have_received(:call)
    end
  end

  context 'with an invalid reason' do
    let(:return_details) do
      { reason: 'not_a_reason', details: 'Detailed reason for return' }
    end

    it 'raises an invalid reason error' do
      expect { command.call }.to raise_error(/has invalid type for :reason/)
      expect(review.state).to eq(:open)
    end

    it 'does not call datastore' do
      expect { command.call }.to raise_error(/has invalid type for :reason/)
      expect(return_request).not_to have_received(:call)
    end
  end

  context 'when a subscribed notifications fails' do
    before do
      allow(NotifyMailer).to receive(:application_returned_email).and_raise(StandardError)
    end

    it 'the return is still recorded' do
      expect { command.call }.to change { review.return_reason }
        .from(nil).to('evidence_issue')
    end
  end

  context 'when the datastore save fails' do
    before do
      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).with(
        {
          application_id: application_id,
          payload: { return_details: },
          member: :return
        }
      ).and_raise(DatastoreApi::Errors::InvalidRequest)
    end

    it 'the return is not recorded' do
      expect { command.call }.to raise_error DatastoreApi::Errors::InvalidRequest
    end
  end
end
