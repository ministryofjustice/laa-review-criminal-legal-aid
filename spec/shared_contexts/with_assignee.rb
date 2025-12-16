require 'rails_helper'

RSpec.shared_context 'with assignee', shared_context: :metadata do
  before do
    allow(CurrentAssignment).to receive(:assigned_to_ids).with(user_id:).and_return([application_id])
  end
end
