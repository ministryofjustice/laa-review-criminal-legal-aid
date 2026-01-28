desc 'Fix the state of application by creating missing events'
task :fix_ghost_application_state, [:application_id, :decision_id, :user_id] => :environment do |task, args|
  application_id = args[:application_id]
  decision_id = args[:decision_id]
  user_id = args[:user_id]
  next if application_id.blank? || decision_id.blank? || user_id.blank?

  review = Review.find_by(application_id:)
  next if review.nil? || review.reviewer_id.present?
  
  event_store = Rails.configuration.event_store
  deciding_stream = "Deciding$#{decision_id}"
  reviewing_stream = "Reviewing$#{application_id}"
  review_aggregate = Reviewing::LoadReview.call(application_id:)

  # estimated timestamps based on the existing events in Review and Datastore
  sent_to_provider_ts = Time.parse('2025-11-18 14:38:16.738541 UTC')
  completed_ts = Time.parse('2025-11-18 14:38:16.75725 UTC')

  sent_to_provider = Deciding::SentToProvider.new(
    data: {
      application_id: application_id,
      decision_id: decision_id.to_i,
      user_id: user_id
    },
    metadata: {
      timestamp: sent_to_provider_ts
    }
  )
  completed = Reviewing::Completed.new(
    data: {
      application_id: application_id,
      reference: review_aggregate.reference,
      submitted_at: review_aggregate.submitted_at,
      parent_id: review_aggregate.parent_id,
      work_stream: review_aggregate.work_stream,
      application_type: review_aggregate.application_type,
      user_id: user_id
    },
    metadata: {
      timestamp: completed_ts
    }
  )

  event_store.publish(sent_to_provider, stream_name: deciding_stream)
  event_store.publish(completed, stream_name: reviewing_stream)
end

desc 'Clear completed application assignments attributed to the wrong assignees'
task clear_ghost_applications: [:environment] do
  CurrentAssignment.pluck(:user_id, :assignment_id).each do |user_id, assignment_id|
    review = Review.closed.find_by(application_id: assignment_id)
    next if review.nil?

    unless review.reviewer_id == user_id
      CurrentAssignment.where(user_id:, assignment_id:).delete_all
    end
  end
end
