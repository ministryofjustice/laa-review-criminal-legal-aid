class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, only: %i[show history]

  def open
    set_search(
      filter: ApplicationSearchFilter.new(
        application_status: 'open'
      )
    )
    @review_status = 'open'

    render :index
  end

  def closed
    set_search(
      filter: ApplicationSearchFilter.new(
        application_status: 'open'
      ),
      default_sort_by: 'reviewed_at'
    )
    @review_status = 'closed'

    render :index
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
      :page,
      sorting: Sorting.attribute_names
    )
  end
end
