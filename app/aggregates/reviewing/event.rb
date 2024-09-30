module Reviewing
  class Event < RailsEventStore::Event
    class << self
      def build(review, data = {})
        review_args = {
          application_id: review.application_id,
          reference: review.reference,
          submitted_at: review.submitted_at,
          parent_id: review.parent_id,
          work_stream: review.work_stream,
          application_type: review.application_type
        }

        new(data: review_args.merge(data))
      end
    end
  end
end
