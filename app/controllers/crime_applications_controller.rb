class CrimeApplicationsController < ApplicationController
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
    flash_and_redirect :success, :completed
  rescue Reviewing::AlreadyCompleted
    flash_and_redirect :important, :already_completed
  rescue Reviewing::CannotCompleteWhenSentBack
    flash_and_redirect :important, :already_sent_back
  end

  def ready
    Reviewing::MarkAsReady.new(
      application_id: @crime_application.id,
      user_id: current_user_id
    ).call
    flash_and_redirect :success, :marked_as_ready
  rescue Reviewing::AlreadyMarkedAsReady
    flash_and_redirect :important, :already_marked_as_ready
  rescue Reviewing::CannotMarkAsReadyWhenSentBack
    flash_and_redirect :important, :already_sent_back
  rescue Reviewing::CannotMarkAsReadyWhenCompleted
    flash_and_redirect :important, :already_completed
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

  def flash_and_redirect(key, message)
    flash[key] = message
    if key == :success
      redirect_to assigned_applications_path
    else
      redirect_to crime_application_path(params[:crime_application_id])
    end
  end
end
