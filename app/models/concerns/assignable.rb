module Assignable
  def assignment
    @assignment ||= Assigning::LoadAssignment.call(
      assignment_id: id
    )
  end

  delegate :assignee_id, :assigned?, :assigned_to?, :unassigned?, to: :assignment

  def assignee_name
    return nil unless assignee_id

    User.name_for(assignee_id)
  end
end
