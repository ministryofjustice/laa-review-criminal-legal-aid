module Reviewable
  def review
    @review ||= Reviewing::LoadReview.call(application_id: id)
  end

  delegate :reviewed_at, :reviewer_id, :reviewed?, :superseded_by, :superseded_at,
           :business_day, :available_reviewer_actions, to: :review

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
      work_stream: work_stream,
      application_type: application_type,
      reference: reference
    )

    @review = nil

    self
  end

  def draft_decisions
    @draft_decisions ||= review.decision_ids.map do |decision_id|
      Deciding::LoadDecision.call(
        application_id: id, decision_id: decision_id
      )
    end
  end

  def status?(status)
    review_status == status
  end

  def superseded?
    !superseded_at.nil?
  end
end
