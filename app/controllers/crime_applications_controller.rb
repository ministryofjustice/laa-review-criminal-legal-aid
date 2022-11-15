class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, except: [:index]

  def index
    @applications = CrimeApplication.all
  end

  def show; end

  def assign_to_self
    @crime_application.assign_to_user(current_user)

    flash[:success] = :assigned_to_you

    redirect_to crime_application_path(@crime_application)
  end

  private

  def set_crime_application
    @crime_application = CrimeApplication.find(params[:id])

    raise ActionController::RoutingError, 'Not Found' unless @crime_application
  end
end
