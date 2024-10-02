module Reviewing
  class AvailableFundingActions
    AVAILABLE_ACTIONS = {
      non_means: {
        open:  [:submit_decision],
      },
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

    def review_type
      return Types::ReviewType[:non_means] if non_means?

      Types::ReviewType[:means]
    end

    def non_means?
      work_stream == Types::WorkStreamType['non_means_tested']
    end

    class << self
      def for(reviewable)
        new(
          state: reviewable.state,
          application_type: reviewable.application_type || Types::ApplicationType['initial'],
          work_stream: reviewable.work_stream
        ).actions
      end
    end
  end
end
