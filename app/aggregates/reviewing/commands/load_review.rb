module Reviewing
  class LoadReview < Command
    def call
      repository.load(Review.new(application_id), stream_name)
    end
  end
end
