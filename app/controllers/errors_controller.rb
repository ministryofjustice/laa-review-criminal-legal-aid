class ErrorsController < BareApplicationController
  layout 'external'
  before_action :authenticate_user!, except: [:forbidden]
  helper_method :assignments_count
  def application_not_found
    respond_with_status(:not_found)
  end

  def not_found
    respond_with_status(:not_found)
  end

  def forbidden
    respond_with_status(:forbidden)
  end

  def unhandled
    respond_with_status(:internal_server_error)
  end

  private

  def respond_with_status(status)
    respond_to do |format|
      format.html { render status: }
      format.all  { head status }
    end
  end

  def assignments_count
    @assignments_count ||= CurrentAssignment.where(
      user_id: current_user.id
    ).count
  end
end
