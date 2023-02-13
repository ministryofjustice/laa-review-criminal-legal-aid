class CrimeApplicationsController < ApplicationController
  before_action :set_crime_application, only: %i[show history]

  def open
    set_search(
      filter: ApplicationSearchFilter.new(application_status: 'open')
    )

    @report = Reporting::WorkloadReport.new

    render :index
  end

  def closed
    set_search(
      filter: ApplicationSearchFilter.new(application_status: 'sent_back'),
      sorting: Sorting.new(sort_by: 'reviewed_at', sort_direction: 'descending')
    )

    @report = Reporting::ProcessedReport.new

    render :index
  end

  def show; end

  def history; end

  private

  def set_crime_application
    @crime_application = ::CrimeApplication.find(params[:id])
  end

  def permitted_params
    params.permit(
      :page,
      :per_page,
      sorting: Sorting.attribute_names
    )
  end
end
