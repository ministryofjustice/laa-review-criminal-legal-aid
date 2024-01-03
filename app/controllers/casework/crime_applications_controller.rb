module Casework
  class CrimeApplicationsController < Casework::BaseController
    include ApplicationSearchable
    include WorkStreamable

    before_action :require_a_user_work_stream, only: %i[open closed]
    before_action :set_current_work_stream, only: %i[open closed]
    before_action :set_crime_application, only: %i[show history complete ready]

    # MOVE TO WORK STREAMS CONTROLLER,
    def open
      set_search(
        default_filter: { application_status: 'open', work_stream: work_stream_filter },
        default_sorting: { sort_by: 'submitted_at', sort_direction: 'ascending' }
      )

      @report_type = Types::Report['current_workload_report']

      render :index
    end

    # MOVE TO WORK STREAMS CONTROLLER,
    def closed
      set_search(
        default_filter: { application_status: 'closed', work_stream: work_stream_filter },
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

    def require_a_user_work_stream
      render :no_work_stream if current_user.work_streams.empty?
    end
  end
end
