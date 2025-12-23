module Casework
  class ReturnsController < Casework::BaseController
    before_action :set_crime_application
    before_action :set_return_details

    def new; end

    def create # rubocop:disable Metrics/MethodLength
      @return_details.validate!

      @crime_application.decision_ids.each do |decision_id|
        Reviewing::RemoveDecision.call(application_id:, user_id:, decision_id:)
      end

      return_details = @return_details.attributes
      Reviewing::SendBack.call(application_id:, user_id:, return_details:)

      flash_and_redirect :success, :sent_back
    rescue ActiveModel::ValidationError
      render :new
    rescue Reviewing::AlreadyReviewed
      flash_and_redirect :important, :already_reviewed
    rescue Reviewing::UnexpectedAssignee
      flash_and_redirect :important, :unexpected_assignee
    end

    private

    alias user_id current_user_id

    def application_id
      @crime_application.id
    end

    def flash_and_redirect(key, message)
      flash[key] = I18n.t(message, scope: [:flash, key])
      if key == :success
        redirect_to assigned_applications_path
      else
        redirect_to crime_application_path(params[:crime_application_id])
      end
    end

    def return_params
      return {} unless params[:return_details]

      params[:return_details].permit(:reason, :details)
    end

    def set_return_details
      @return_details = ReturnDetails.new(return_params)
    end
  end
end
