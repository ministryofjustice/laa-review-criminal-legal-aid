class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, except: [:index]

  def index
    @applications = CrimeApplication.all
  end

  def show; end

  def history; end

  private

  def set_crime_application
    @crime_application = CrimeApplication.find(params[:id])

    raise ActionController::RoutingError, 'Not Found' unless @crime_application
  end
end
