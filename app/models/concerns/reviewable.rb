module Reviewable
  def review
    @review ||= load_review!
  end

  delegate :reviewed_at, :reviewer_id, :reviewed?, to: :review

  def review_status
    review.state
  end

  def reviewer_name
    return nil unless reviewer_id

    User.name_for(reviewer_id)
  end

  def load_review!
    review = Reviewing::LoadReview.call(application_id: id)

    unless review.received?
      Reviewing::ReceiveApplication.call(
        application_id: id,
        submitted_at: submitted_at
      )
    end

    review
  end
end
