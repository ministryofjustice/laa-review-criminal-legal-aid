require 'rails_helper'

RSpec.describe Reviewing::ReceiveApplication do
  subject(:command) do
    described_class.new(application_id:)
  end

  include_context 'with review'

  it 'changes the state from :nil to :received' do
    expect { command.call }.to change { review.state }
      .from(nil).to(:received)
  end
end
