class ApplicationController < ActionController::Base
  rescue_from ApiResource::NotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found

  before_action :authenticate_user!
  helper_method :current_user
  helper_method :assignments_count

  private

  def assignments_count
    current_user.assigned_applications.count
  end

  def current_user
    warden.user
  end

  def authenticate_user!
    warden.authenticate!(:azure_ad)
  end

  def warden
    request.env['warden']
  end

  # TODO: bring over error pages from Apply
  def not_found
    render plain: '404 Not Found', status: :not_found
  end
end
