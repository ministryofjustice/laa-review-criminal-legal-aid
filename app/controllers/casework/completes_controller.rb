module Casework
  class CompletesController < Casework::BaseController
    before_action :set_crime_application, only: %i[show create]

    def show; end

    def create
      Reviewing::Complete.new(
        application_id: @crime_application.id,
        user_id: current_user_id,
        decisions: @crime_application.draft_decisions.map(&:attributes)
      ).call

      # set_flash :completed
      redirect_to crime_application_complete_path(@crime_application)
    rescue Reviewing::Error => e
      set_flash(e.message_key, success: false)
      redirect_to crime_application_path(@crime_application)
    end
  end
end