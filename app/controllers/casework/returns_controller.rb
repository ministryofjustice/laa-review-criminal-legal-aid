module Casework
  class ReturnsController < Casework::BaseController
    before_action :set_crime_application

    def new
      @return_details = ReturnDetails.new
    end

    def create
      @return_details = ReturnDetails.new(return_params)

      @return_details.validate!

      Reviewing::SendBack.new(
        application_id: params[:crime_application_id],
        user_id: current_user_id,
        return_details: @return_details.attributes
      ).call

      flash_and_redirect :success, :sent_back
    rescue ActiveModel::ValidationError
      render :new
    rescue Reviewing::AlreadyReviewed
      flash_and_redirect :important, :already_reviewed
    end

    private

    def flash_and_redirect(key, message)
      flash[key] = I18n.t(message, scope: [:flash, key])
      if key == :success
        redirect_to assigned_applications_path
      else
        redirect_to crime_application_path(params[:crime_application_id])
      end
    end

    def return_params
      params[:return_details].permit(:reason, :details)
    end
  end
end
