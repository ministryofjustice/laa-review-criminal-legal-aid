class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, except: [:index]

  def index
    case params[:status]
    when 'open'
      @applications = CrimeApplication.open
    when 'closed'
      @applications = CrimeApplication.closed
    end
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
