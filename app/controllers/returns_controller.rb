class ReturnsController < ApplicationController
  before_action :set_crime_application

  def new
    @return_reason = ReturnReason.new()
  end

  def create
    @return_reason = ReturnReason.new(return_params)

    if @return_reason.valid?(:send_back)
      Reviewing::SendBack.new(
        application_id: params[:crime_application_id],
        user_id: current_user_id,
        reason: @return_reason.attributes
      ).call

      flash[key] = message
      redirect_to @crime_application
    else
      render :new
    end
  end

  private

  def flash_and_redirect(key, message)
    flash[key] = message
    redirect_to crime_application_path(params[:crime_application_id])
  end

  def return_params
    params[:return_reason].permit(*Types::ReturnReasonSchema.types.keys).to_h.symbolize_keys
  end

  def set_crime_application
    @crime_application = CrimeApplication.find(params[:crime_application_id])
  end
end
