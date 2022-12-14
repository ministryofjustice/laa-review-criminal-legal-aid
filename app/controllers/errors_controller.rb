class ErrorsController < ApplicationController
  def application_not_found
    respond_with_status(:not_found)
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
end
