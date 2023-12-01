require 'rails_helper'

RSpec.describe Reviewing::MarkAsReady do
  subject(:command) do
    described_class.new(application_id:, user_id:)
  end

  include_context 'with review'

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).with(
      {
        application_id: application_id,
        payload: true,
        member: :mark_as_ready
      }
    ).and_return(return_request)

    Reviewing::ReceiveApplication.call(
      application_id: application_id, submitted_at: 1.day.ago.to_s, work_stream: 'extradition'
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

  it 'changes the state from :received to :marked_as_ready' do
    expect { command.call }.to change { review.state }
      .from(:open).to(:marked_as_ready)
  end
end
