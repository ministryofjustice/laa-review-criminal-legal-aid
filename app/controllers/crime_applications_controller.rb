class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, except: [:index]

  def index
    status = params[:status]

    @filter = ApplicationSearchFilter.new

    @applications = CrimeApplication.all.select { |ca| ca.status == status.to_s }
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
