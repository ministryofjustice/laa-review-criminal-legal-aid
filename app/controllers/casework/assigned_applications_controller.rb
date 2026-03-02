module Casework
  class AssignedApplicationsController < Casework::BaseController
    include ApplicationSearchable
    include WorkStreamable
    include CaseworkHelper

    before_action :set_crime_application, only: [:create, :destroy]

    before_action :require_a_user_work_stream, only: [:next_application]
    before_action :require_app_work_stream, only: [:create]

    def index
      return unless assignments_count.positive?

      set_search(
        default_filter: { assigned_status: current_user_id, application_status: 'open' },
        default_sorting: { sort_by: 'submitted_at', sort_direction: 'ascending' }
      )
    end

    def create
      Assigning::AssignToUser.new(
        assignment_id: params[:crime_application_id],
        user_id: current_user_id,
        to_whom_id: current_user_id,
        reference: current_crime_application.reference
      ).call

      set_flash(:assigned_to_self)
      redirect_to crime_application_path(params[:crime_application_id])
    end

    def next_application
      next_app_id = GetNext.call(work_streams: current_user.work_streams,
                                 application_types: current_user.application_types_competencies)
      if next_app_id
        app = assign_application(next_app_id)
        redirect_to application_start_path(app)
      else
        set_flash(:no_next_to_assign, success: false)
        redirect_to assigned_applications_path
      end
    end

    def destroy
      current_assignment = CurrentAssignment.find_by!(
        assignment_id: params[:id],
        user_id: current_user_id
      )

      Assigning::UnassignFromUser.new(
        assignment_id: current_assignment.assignment_id,
        user_id: current_user_id,
        from_whom_id: current_user_id,
        reference: current_crime_application.reference
      ).call

      set_flash(:unassigned_from_self)
      redirect_to assigned_applications_path
    end

    private

    def require_a_user_work_stream
      return unless current_user.work_streams.empty?

      set_flash(:no_work_streams_to_assign_from, success: false)

      redirect_to assigned_applications_path
    end

    def assign_application(next_app_id)
      application = CrimeApplication.find(next_app_id)
      Assigning::AssignToUser.new(
        assignment_id: next_app_id, user_id: current_user_id, to_whom_id: current_user_id,
        reference: application.reference
      ).call

      set_flash(:assigned_to_self)
      application
    end
  end
end
