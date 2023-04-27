module Reviews
  class UpdateFromAggregate
    #
    # Handle Reviewing events by updating the Review read model.
    #
    # When passed an event, update the Review read model attributes
    # with those from the corresponding event sourced Reviewing::Review
    # aggregate.
    #
    def call(event)
      application_id = event.data.fetch(:application_id, nil)
      return unless application_id

      update_from_aggregate(Reviewing::LoadReview.call(application_id:))
    end

    private

    def update_from_aggregate(review)
      Review.upsert(
        {
          application_id: review.id,
          state: review.state,
          submitted_at: review.submitted_at,
          reviewer_id: review.reviewer_id,
          parent_id: review.parent_id,
        },
        unique_by: :application_id
      )
    end
  end
end
