module Reviewable
  def review
    @review ||= Reviewing::LoadReview.call(application_id: id)
  end

  delegate :reviewed_at, :reviewer_id, :reviewed?, :superseded_by, :superseded_at,
           :business_day, :available_reviewer_actions, :decision_ids, to: :review

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
    @draft_decisions ||= decision_ids.map do |decision_id|
      Decisions::Draft.build(
        Deciding::LoadDecision.call(
          application_id: id, decision_id: decision_id
        )
      )
    end
  end

  def means_tested?
    work_stream != ::Types::WorkStreamType['non_means_tested']
  end

  def status?(status)
    review_status == status
  end

  def superseded?
    !superseded_at.nil?
  end
end
