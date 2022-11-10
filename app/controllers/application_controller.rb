class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  helper_method :current_user

  private

  # def current_user
  #   warden.user
  # end

  def authenticate_user!
    warden.authenticate!(:azure_ad)
  end

  def warden
    request.env['warden']
  end
end
