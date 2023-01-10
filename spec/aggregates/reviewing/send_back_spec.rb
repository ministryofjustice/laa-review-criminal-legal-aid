require 'rails_helper'

RSpec.describe Reviewing::SendBack do
  subject(:command) do
    described_class.new(application_id:, user_id:, reason:)
  end

  include_context 'with review'

  let(:user_id) { SecureRandom.uuid }
  let(:reason) { { selected_reason: 'evidence_issue' } }

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
        .from(nil).to(reason)
    end
  end

  context 'with an invalid reason' do
    let(:reason) { { selected_reason: 'not_a_reason' } }

    it 'raises an invalid reason error' do
      expect { command.call }.to raise_error(/has invalid type for :reason/)
      expect(review.state).to eq(:received)
    end
  end
end
