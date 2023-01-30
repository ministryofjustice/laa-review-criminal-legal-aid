class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, except: %i[index]

  def index
    default_sorting_params = {}
    if params[:status] == 'closed'
      @review_status = 'closed'
      application_status = 'sent_back'
      default_sorting_params[:sort_by] = 'reviewed_at'
    else
      @review_status = 'open'
      application_status = 'open'
    end

    @sorting = Sorting.new(permitted_params[:sorting] || default_sorting_params)
    @filter = ApplicationSearchFilter.new(application_status:)
    @search = ApplicationSearch.new(filter: @filter, sorting: @sorting)
  end

  def show
    @current_assignment = @crime_application.current_assignment
  end

  def history; end

  private

  def set_crime_application
    @crime_application = ::CrimeApplication.find(params[:id])
  end

  def permitted_params
    params.permit(
      :status,
      sorting: Sorting.attribute_names
    )
  end
end
