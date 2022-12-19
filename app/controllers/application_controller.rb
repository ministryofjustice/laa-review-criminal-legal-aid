class ApplicationController < ActionController::Base
  include ErrorHandling

  before_action :authenticate_user!
  helper_method :current_user_id
  helper_method :assignments_count

  private

  def assignments_count
    @assignments_count ||= CurrentAssignment.where(
      user_id: current_user_id
    ).count
  end

  # def current_user
  #   warden.user
  # end
  
  def current_user_id
    warden.user.first
  end

  def authenticate_user!
    warden.authenticate!(:azure_ad)
  end

  def warden
    request.env['warden']
  end
end
