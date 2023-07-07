class CrimeApplicationsController < ServiceController
  before_action :set_crime_application, only: %i[show history complete ready]

  def open
    set_search(
      filter: ApplicationSearchFilter.new(application_status: 'open')
    )

    @report = Reporting::WorkloadReport.new

    render :index
  end

  def closed
    set_search(
      filter: ApplicationSearchFilter.new(application_status: 'closed'),
      sorting: Sorting.new(sort_by: 'reviewed_at', sort_direction: 'descending')
    )

    @report = Reporting::ProcessedReport.new

    render :index
  end

  def show; end

  def history; end

  def complete
    Reviewing::Complete.new(
      application_id: @crime_application.id,
      user_id: current_user_id
    ).call

    set_flash :completed
    redirect_to assigned_applications_path
  rescue Reviewing::Error => e
    set_flash(e.message_key, success: false)
    redirect_to crime_application_path(@crime_application)
  end

  def ready
    Reviewing::MarkAsReady.new(
      application_id: @crime_application.id,
      user_id: current_user_id
    ).call

    set_flash :marked_as_ready
  rescue Reviewing::Error => e
    set_flash(e.message_key, success: false)
  ensure
    redirect_to crime_application_path(@crime_application)
  end

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
