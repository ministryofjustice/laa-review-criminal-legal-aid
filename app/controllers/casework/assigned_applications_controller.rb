module Casework
  class AssignedApplicationsController < Casework::BaseController
    include ApplicationSearchable
    before_action :set_crime_application, only: %i[create]

    def index
      return unless assignments_count.positive?

      set_search(
        default_filter: { assigned_status: current_user_id },
        default_sorting: { sort_by: 'submitted_at', sort_direction: 'ascending' }
      )
    end

    def create # rubocop:disable Metrics/AbcSize
      return require_work_stream_flash if current_user.work_streams.empty?
      return require_app_work_stream_flash if current_user.work_streams.exclude?(@crime_application.work_stream)

      Assigning::AssignToUser.new(
        assignment_id: params[:crime_application_id],
        user_id: current_user_id,
        to_whom_id: current_user_id
      ).call

      flash_and_redirect(:success, :assigned_to_self, params[:crime_application_id])
    end

    def next_application
      return require_work_stream_flash if current_user.work_streams.empty?

      next_app_id = GetNext.call(work_streams: current_user.work_streams)

      if next_app_id
        Assigning::AssignToUser.new(
          assignment_id: next_app_id, user_id: current_user_id, to_whom_id: current_user_id
        ).call

        flash_and_redirect(:success, :assigned_to_self, next_app_id)
      else
        flash_and_redirect(:important, :no_next_to_assign)
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
        from_whom_id: current_user_id
      ).call

      flash_and_redirect(:success, :unassigned_from_self)
    end

    private

    def flash_and_redirect(key, message, resource_id = nil, options = {})
      flash[key] = I18n.t(message, scope: [:flash, key], **options)

      if resource_id
        redirect_to crime_application_path(resource_id)
      else
        redirect_to assigned_applications_path
      end
    end

    def require_work_stream_flash
      flash_and_redirect(:important, :no_work_streams_to_assign_from, params[:crime_application_id])
    end

    def require_app_work_stream_flash
      flash_and_redirect(:important,
                         :not_allocated_to_appropriate_work_stream,
                         params[:crime_application_id],
                         work_queue: WorkStream.new(@crime_application.work_stream).to_param.humanize)
    end
  end
end
