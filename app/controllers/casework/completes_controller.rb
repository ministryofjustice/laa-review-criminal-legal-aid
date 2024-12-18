module Casework
  class CompletesController < Casework::BaseController
    before_action :set_crime_application

    def create
      Reviewing::Complete.new(
        application_id: @crime_application.id,
        user_id: current_user_id
      ).call

      set_flash :completed

      redirect_to assigned_applications_path
    rescue Reviewing::Error => e
      set_flash(e.message_key, success: false)

      redirect_to crime_application_path(@crime_application)
    end
  end
end
