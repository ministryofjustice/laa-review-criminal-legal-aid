module Reviewing
  class AvailableReviewerActions
    include TypeOfApplication

    AVAILABLE_ACTIONS = {
      means: {
        open: [:mark_as_ready, :send_back],
        marked_as_ready: [:complete, :send_back],
      },
      cifc: {
        open: [:complete, :send_back],
        marked_as_ready: [:complete, :send_back]
      },
      non_means: {
        open:  [:complete, :send_back],
      },
      pse: {
        open: [:complete]
      }
    }.freeze

    AVAILABLE_ACTIONS_WITH_DECISIONS = {
      means: {
        open: [:mark_as_ready, :send_back],
        marked_as_ready: [:send_back],
      },
      cifc: {
        open: [:send_back],
        marked_as_ready: [:send_back]
      },
      non_means: {
        open:  [:send_back],
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
      config.dig(review_type, state) || []
    end

    private

    def config
      return AVAILABLE_ACTIONS_WITH_DECISIONS if FeatureFlags.adding_decisions.enabled?

      AVAILABLE_ACTIONS
    end

    def review_type
      return Types::ReviewType[:cifc] if cifc?
      return Types::ReviewType[:pse] if pse?
      return Types::ReviewType[:non_means] if non_means?

      Types::ReviewType[:means]
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
