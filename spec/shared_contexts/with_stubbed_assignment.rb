require 'rails_helper'

RSpec.shared_context 'with stubbed assignment', shared_context: :metadata do
  let(:user_id) { SecureRandom.uuid }
  let(:application_id) { SecureRandom.uuid }
  let(:assignment) do
    instance_double(Assigning::Assignment, id: application_id, state: :assigned, assignee_id: user_id)
  end

  before do
    allow(Assigning::LoadAssignment).to receive(:call).and_return(assignment)
    allow(assignment).to receive_messages(assigned_to?: true, unassigned?: false)
  end
end
