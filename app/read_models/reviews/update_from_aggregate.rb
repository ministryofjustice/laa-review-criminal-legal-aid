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

      review_aggregate = Reviewing::LoadReview.call(application_id:)

      update_from_aggregate(review_aggregate)
    end

    private

    def update_from_aggregate(review_aggregate)
      Review.upsert(
        {
          application_id: review_aggregate.id,
          state: review_aggregate.state,
          submitted_at: review_aggregate.submitted_at,
          reviewer_id: review_aggregate.reviewer_id,
          parent_id: review_aggregate.parent_id,
        },
        unique_by: :application_id
      )
    end
  end
end