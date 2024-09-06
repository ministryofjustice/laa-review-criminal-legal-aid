module Casework
  class FundingDecisionsController < Casework::BaseController
    before_action :set_crime_application

    def new
      render 'decisions/interests_of_justice/edit'
      # @form_object = Decisions::InterestsOfJustice.new
    end

    def create
      throw params
    end

    # rubocop:disable Metrics/MethodLength
    def update
      @return_details = Decisions::InterestsOfJustice.new(return_params)

      @return_details.validate!

      Reviewing::EditDecision.new(
        application_id: params[:crime_application_id],
        user_id: current_user_id,
        decision_details: @return_details.attributes
      ).call

      flash_and_redirect :success, :sent_back
    rescue ActiveModel::ValidationError
      render :new
    rescue Reviewing::AlreadySentBack
      flash_and_redirect :important, :already_sent_back
    rescue Reviewing::CannotSendBackWhenCompleted
      flash_and_redirect :important, :cannot_send_back_when_completed
    end
    # rubocop:enable Metrics/MethodLength

    private

    def flash_and_redirect(key, message)
      flash[key] = I18n.t(message, scope: [:flash, key])
      if key == :success
        redirect_to assigned_applications_path
      else
        redirect_to crime_application_path(params[:crime_application_id])
      end
    end

    def step_params
      params[:return_details].permit(:reason, :details)
    end
  end
end
