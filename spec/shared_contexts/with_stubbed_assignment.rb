require 'rails_helper'

RSpec.shared_context 'with stubbed assignment', shared_context: :metadata do
  let(:user_id) { SecureRandom.uuid }
  let(:application_id) { SecureRandom.uuid }

  before do
    allow(CurrentAssignment).to receive(:assigned_to_ids).with(user_id:).and_return([application_id])
  end
end
