module Reviews
  class UpdateFromAggregate
    #
    # Handle Reviewing events by updating the Review read model.
    #
    # When passed an event, update the Review read model attributes
    # with those from the corresponding event sourced aggregate.
    #
    def call(event)
      application_id = event.data.fetch(:application_id, nil)
      return unless application_id

      update_from_aggregate(application_id:)
    end

    def update_from_aggregate(application_id:) # rubocop:disable Metrics/MethodLength
      review_aggregate = Reviewing::LoadReview.call(application_id:)

      Review.upsert(
        {
          application_id: review_aggregate.id,
          state: review_aggregate.state,
          submitted_at: review_aggregate.submitted_at,
          reviewer_id: review_aggregate.reviewer_id,
          parent_id: review_aggregate.parent_id,
          business_day: review_aggregate.business_day.to_s,
          application_type: review_aggregate.application_type,
          reviewed_on: review_aggregate.reviewed_on,
          work_stream: review_aggregate.work_stream
        },
        unique_by: :application_id
      )
    end
  end
end
