class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, except: [:index]
  def index
    @applications = CrimeApplication.all
  end

  def show
    raise ActionController::RoutingError, 'Not Found' unless @crime_application
  end

  # FIXME, tmp home for assign until command pattern determined.
  def assign_to_self
    flash.now[:success] = 'This application has been assigned to you'
    render :show
  end

  private

  def set_crime_application
    @crime_application = CrimeApplication.find(params[:id])
  end
end
