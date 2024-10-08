require 'rails_helper'

RSpec.describe Reviewing::Complete do
  subject(:command) do
    described_class.new(application_id:, user_id:)
  end

  include_context 'with review'

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).with(
      {
        application_id: application_id,
        payload: { decisions: [] },
        member: :complete
      }
    ).and_return(return_request)

    Reviewing::ReceiveApplication.call(
      application_id: application_id, submitted_at: 1.day.ago.to_s, work_stream: 'extradition',
      application_type: 'initial', reference: 123
    )
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

  it 'changes the state from :received to :completed' do
    expect { command.call }.to change { review.state }
      .from(:open).to(:completed)
  end

  context 'when there are incomplete decisions' do
    before do
      args = {
        application_id: application_id,
        user_id: SecureRandom.uuid,
        decision_id: SecureRandom.uuid
      }

      Reviewing::AddDecision.call(**args)
      Deciding::CreateDraft.call(**args)
    end

    it 'throws an error' do
      expect do
        command.call
      end.to raise_error(Reviewing::IncompleteDecisions)
    end
  end
end
