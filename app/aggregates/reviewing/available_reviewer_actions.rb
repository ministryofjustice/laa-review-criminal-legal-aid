module Reviewing
  class AvailableReviewerActions
    AVAILABLE_ACTIONS = {
      means: {
        open: [:mark_as_ready, :send_back],
        marked_as_ready: [:complete, :send_back],
      },
      non_means: {
        open: [:complete, :send_back],
        marked_as_ready: [:complete, :send_back] # TODO: remove once all non-means in this state processed
      },
      pse: {
        open: [:complete]
      }
    }.freeze

    def initialize(state:, application_type:, work_stream:)
      @application_type = application_type
      @state = state
      @work_stream = work_stream
    end

    attr_reader :state, :application_type, :work_stream

    def actions
      AVAILABLE_ACTIONS.dig(review_type, state) || []
    end

    private

    # review_type is an experimental field derived from application_type
    # and assessment_type. It is intended to help determine the set of
    # actions a reviewer may need to take for a specific application.
    def review_type
      return Types::ReviewType[:pse] if pse?
      return Types::ReviewType[:non_means] if non_means?

      Types::ReviewType[:means]
    end

    def pse?
      application_type == Types::ApplicationType['post_submission_evidence']
    end

    def non_means?
      work_stream == Types::WorkStreamType['non_means_tested']
    end

    class << self
      def for(reviewable)
        new(
          state: reviewable.state,
          application_type: reviewable.application_type || 'initial',
          work_stream: reviewable.work_stream
        ).actions
      end
    end
  end
end
