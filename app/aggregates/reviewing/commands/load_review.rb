module Reviewing
  class LoadReview < Command
    def call
      review = repository.load(Review.new(application_id), stream_name)

      # Ensure applications are received before being returned
      if review.state.nil?
        review.receive_application(application_id:)
        repository.store(review, stream_name)
      end

      review
    end
  end
end
