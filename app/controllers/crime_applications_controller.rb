class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, except: [:index]

  def index
    @filter = ApplicationSearchFilter.new

    @applications = CrimeApplication.all
  end

  def show
    @current_assignment = @crime_application.current_assignment
  end

  def history; end

  private

  def set_crime_application
    @crime_application = ::CrimeApplication.find(params[:id])
  end
end
