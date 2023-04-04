class ReassignsController < ApplicationController
  def new
    @current_assignment = CurrentAssignment.find_by!(
      assignment_id: params[:crime_application_id]
    )
  end

  def create
    reassign_to_self
  rescue Assigning::CannotReassignUnlessAssigned
    flash_and_redirect(:important, :unassigned_before_confirm)
  rescue Assigning::StateHasChanged
    flash_and_redirect(:important, :reassigned_to_someone_else)
  else
    flash_and_redirect(:success, :assigned_to_self)
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

  def flash_and_redirect(key, message)
    flash[key] = I18n.t(message, scope: [:flash, key])
    redirect_to crime_application_path(params[:crime_application_id])
  end
end
