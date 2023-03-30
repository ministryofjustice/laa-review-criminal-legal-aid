class AssignedApplicationsController < ApplicationController
  def index
    return unless assignments_count.positive?

    set_search(
      filter: ApplicationSearchFilter.new(assigned_status: current_user_id)
    )
  end

  def create
    Assigning::AssignToUser.new(
      assignment_id: params[:crime_application_id],
      user_id: current_user_id,
      to_whom_id: current_user_id
    ).call

    flash_and_redirect(:success, :assigned_to_self, params[:crime_application_id])
  end

  def next_application
    next_app_id = GetNext.new.call

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

  def flash_and_redirect(key, message, resource_id = nil)
    flash[key] = I18n.t(message, scope: [:flash, key])

    if resource_id
      redirect_to crime_application_path(resource_id)
    else
      redirect_to assigned_applications_path
    end
  end

  def permitted_params
    params.permit(
      :page,
      :per_page,
      sorting: Sorting.attribute_names
    )
  end
end
