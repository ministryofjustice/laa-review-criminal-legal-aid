module Casework
  class ReassignsController < Casework::BaseController
    before_action :set_crime_application
    def new
      @current_assignment = current_assignment
    end

    def create # rubocop:disable Metrics/AbcSize,
      return require_work_stream_flash if current_user.work_streams.empty?
      return require_app_work_stream_flash if current_user.work_streams.exclude?(@crime_application.work_stream)

      reassign_to_self
      set_flash(:assigned_to_self)
    rescue Assigning::CannotReassignUnlessAssigned, ActiveRecord::RecordNotFound
      set_flash(:unassigned_before_confirm, success: false)
    rescue Assigning::StateHasChanged
      set_flash(:reassigned_to_someone_else,
                reassigned_to_user: User.name_for(current_assignment.user_id), success: false)
    ensure
      redirect_to crime_application_path(params[:crime_application_id])
    end

    private

    def reassign_to_self
      Assigning::ReassignToUser.new(
        assignment_id: params[:crime_application_id],
        user_id: current_user_id,
        from_whom_id: params[:from_whom_id],
        to_whom_id: current_user_id
      ).call
    end

    def current_assignment
      CurrentAssignment.find_by!(
        assignment_id: params[:crime_application_id]
      )
    end

    def require_work_stream_flash
      set_flash(:no_work_streams_to_assign_from, success: false)
    end

    def require_app_work_stream_flash
      set_flash(:not_allocated_to_appropriate_work_stream,
                success: false, work_queue: WorkStream.new(@crime_application.work_stream).to_param.humanize)
    end
  end
end
