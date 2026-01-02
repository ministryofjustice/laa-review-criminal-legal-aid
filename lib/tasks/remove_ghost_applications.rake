desc 'Remove completed application assignments attributed to the wrong assignees'
task remove_ghost_applications: [:environment] do
  CurrentAssignment.pluck(:user_id, :assignment_id).each do |user_id, assignment_id|
    review = Review.closed.find_by(application_id: assignment_id)
    next if review.nil?

    unless review.reviewer_id == user_id
      CurrentAssignment.where(user_id:, assignment_id:).delete_all
    end
  end
end
