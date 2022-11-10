class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:logout]

  def create
    redirect_to root_path
  end

  # This is the logout url for Azure Ad Single Sign Out.
  def logout
    warden.logout

    head :ok
  end
end
