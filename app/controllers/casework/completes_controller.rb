module Casework
  class CompletesController < Casework::BaseController
    before_action :set_crime_application

    def create
      Reviewing::Complete.new(
        application_id: @crime_application.id,
        user_id: current_user_id
      ).call

      set_flash with_decisions ? :completed_with_decisions : :completed

      redirect_to assigned_applications_path
    rescue Reviewing::Error => e
      set_flash(e.message_key, success: false)

      redirect_to failure_path
    end

    private

    def failure_path
      if with_decisions
        crime_application_decisions_path(@crime_application)
      else
        crime_application_path(@crime_application)
      end
    end

    # TODO: remove once adding decision feature fully enabled
    def with_decisions
      @with_decisions ||= @crime_application.review.decision_ids.present?
    end
  end
end
