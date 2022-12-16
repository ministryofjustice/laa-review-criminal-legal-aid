class ApplicationController < ActionController::Base
  include ErrorHandling

  before_action :authenticate_user!
  helper_method :current_user
  helper_method :assignments_count

  private

  def assignments_count
    current_user.current_assignments.count
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
end
