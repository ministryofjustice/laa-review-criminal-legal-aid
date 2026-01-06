module AssignmentHelpers
  def with_assignment(user_id:, assignment_id:)
    assignment = instance_double(Assigning::Assignment, id: assignment_id, state: :assigned, assignee_id: user_id)
    allow(Assigning::LoadAssignment).to receive(:call).and_return(assignment)
    allow(assignment).to receive_messages(assigned_to?: true, unassigned?: false)
    yield if block_given?
  ensure
    RSpec::Mocks.space.proxy_for(Assigning::LoadAssignment).reset
  end
end
