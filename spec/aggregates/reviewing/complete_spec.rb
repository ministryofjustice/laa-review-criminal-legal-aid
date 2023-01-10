require 'rails_helper'

RSpec.describe Reviewing::Complete do
  subject(:command) do
    described_class.new(application_id:, user_id:)
  end

  include_context 'with review'

  before do
    Reviewing::ReceiveApplication.new(application_id:).call
  end

  let(:user_id) { SecureRandom.uuid }

  it 'changes the state from :received to :completed' do
    expect { command.call }.to change { review.state }
      .from(:received).to(:completed)
  end
end
