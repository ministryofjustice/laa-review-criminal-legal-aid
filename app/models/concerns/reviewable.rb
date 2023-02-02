module Reviewable
  def review
    Reviewing::LoadReview.new(
      application_id: id
    ).call
  end

  delegate :reviewed_at, :reviewer_id, :reviewed?, to: :review

  def review_status
    review.state
  end

  def reviewer_name
    return nil unless reviewer_id

    User.name_for(reviewer_id)
  end
end
