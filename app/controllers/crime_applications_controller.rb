class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, except: %i[index]

  def index
    if params[:status] == 'closed'
      @review_status = 'closed'
      filter = ApplicationSearchFilter.new(application_status: 'sent_back')
    else
      @review_status = 'open'
      filter = ApplicationSearchFilter.new(application_status: 'open')
    end

    @search = ApplicationSearch.new(filter:)
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
