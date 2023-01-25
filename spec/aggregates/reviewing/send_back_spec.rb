require 'rails_helper'

RSpec.describe Reviewing::SendBack do
  subject(:command) do
    described_class.new(application_id:, user_id:, return_details:)
  end

  include_context 'with review'

  let(:user_id) { SecureRandom.uuid }

  let(:return_details) do
    { reason: 'evidence_issue', details: 'Detailed reason for return' }
  end

  before do
    Reviewing::ReceiveApplication.new(application_id:).call
  end

  context 'with a valid reason' do
    it 'changes the state from :received to :sent_back' do
      expect { command.call }.to change { review.state }
        .from(:received).to(:sent_back)
    end

    it 'records the return reason' do
      expect { command.call }.to change { review.return_reason }
        .from(nil).to('evidence_issue')
    end
  end

  context 'with an invalid reason' do
    let(:return_details) do
      { reason: 'not_a_reason', details: 'Detailed reason for return' }
    end

    it 'raises an invalid reason error' do
      expect { command.call }.to raise_error(/has invalid type for :reason/)
      expect(review.state).to eq(:received)
    end
  end
end
