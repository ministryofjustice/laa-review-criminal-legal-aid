module AsssignmentHelpers
  def with_assignment(user_id:, assignment_id:)
    allow(CurrentAssignment).to receive(:assigned_to_ids).with(user_id:).and_return([assignment_id])
    yield if block_given?
  ensure
    RSpec::Mocks.space.proxy_for(CurrentAssignment).reset
  end
end
