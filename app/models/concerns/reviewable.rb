module Reviewable
  def review
    @review ||= Reviewing::LoadReview.call(application_id: id)
  end

  delegate :reviewed_at, :reviewer_id, :reviewed?, :superseded_by, :superseded_at,
           :business_day, to: :review

  def review_status
    review.state
  end

  def reviewer_name
    return nil unless reviewer_id

    User.name_for(reviewer_id)
  end

  def receive_if_required!
    return self if review.received?

    Reviewing::ReceiveApplication.call(
      application_id: id,
      submitted_at: submitted_at,
      parent_id: parent_id,
      work_stream: work_stream
    )

    @review = nil

    self
  end

  def status?(status)
    review_status == status
  end

  def application_type?(application_type)
    self.application_type == Types::ApplicationType[application_type.to_s]
  end

  def superseded?
    !superseded_at.nil?
  end
end
