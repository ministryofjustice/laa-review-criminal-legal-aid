require 'rails_helper'

RSpec.describe Reviewing::ReceiveApplication do
  subject(:command) do
    described_class.new(
      application_id: application_id, submitted_at: Time.zone.now.to_s, parent_id: nil
    )
  end

  include_context 'with review'

  it 'changes the state from :nil to :received' do
    expect { command.call }.to change { review.state }
      .from(nil).to(:open)
  end
end
