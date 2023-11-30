module Casework
  class CrimeApplicationsController < Casework::BaseController
    include ApplicationSearchable

    before_action :set_crime_application, only: %i[show history complete ready]

    def open
      set_search(
        default_filter: { application_status: 'open', work_stream: current_work_stream },
        default_sorting: { sort_by: 'submitted_at', sort_direction: 'ascending' }
      )

      @report_type = Types::Report['current_workload_report']

      render :index
    end

    def closed
      set_search(
        default_filter: { application_status: 'closed', work_stream: current_work_stream },
        default_sorting: { sort_by: 'reviewed_at', sort_direction: 'descending' }
      )

      @report_type = Types::Report['processed_report']

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
  end
end
