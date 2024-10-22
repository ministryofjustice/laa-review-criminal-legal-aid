module Reviewing
  class AvailableReviewerActions
    AVAILABLE_ACTIONS = {
      means: {
        open: [:mark_as_ready, :send_back],
        marked_as_ready: [:complete, :send_back],
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
      non_means: {
        open:  [:send_back],
      },
      pse: {
        open: [:complete]
      }
    }.freeze

    def initialize(state:, application_type:, work_stream:, has_decisions:)
      @application_type = application_type
      @state = state
      @work_stream = work_stream
      @has_decisions = has_decisions
    end

    attr_reader :state, :application_type, :work_stream, :has_decisions

    def actions
      config.dig(review_type, state).dup || []
    end

    private

    def config
      return AVAILABLE_ACTIONS_WITH_DECISIONS if FeatureFlags.adding_decisions.enabled?

      AVAILABLE_ACTIONS
    end

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
          application_type: reviewable.application_type || Types::ApplicationType['initial'],
          work_stream: reviewable.work_stream,
          has_decisions: reviewable.decision_ids.any?
        ).actions
      end
    end
  end
end
