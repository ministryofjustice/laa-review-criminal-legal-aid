require 'rails_helper'

RSpec.describe Reviewing::SendBack do
  subject(:command) do
    described_class.new(application_id:, user_id:, return_details:)
  end

  before do
    Reviewing::ReceiveApplication.new(application_id:).call

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
end
