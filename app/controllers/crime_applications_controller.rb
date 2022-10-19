class CrimeApplicationsController < ApplicationController
  def index
    @applications = CrimeApplication.all
  end

  def show
    @crime_application = CrimeApplication.find(params[:id])

    raise ActionController::RoutingError, 'Not Found' unless @crime_application
  end
end
