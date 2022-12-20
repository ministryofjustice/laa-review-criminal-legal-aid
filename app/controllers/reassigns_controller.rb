class ReassignsController < ApplicationController
  def new
    @current_assignment = CurrentAssignment.find_by!(assignment_id: params[:crime_application_id])

    return if @current_assignment

    raise ApiResource::NotFound, 'Not Found'
  end

  def create
    reassign_to_self
  rescue Assigning::StateHasChanged
    flash_and_redirect(:important, :state_has_changed)
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
    flash[key] = message
    redirect_to crime_application_path(params[:crime_application_id])
  end
end
