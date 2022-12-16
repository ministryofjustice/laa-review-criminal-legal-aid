class ReassignsController < ApplicationController
  def new
    @current_assignment = CurrentAssignment.new(
      assignment_id: params[:crime_application_id]
    )

    return if @current_assignment&.assigned?

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
    Assigning::ReassignToSelf.new(
      assignment_id: params[:crime_application_id],
      user: current_user,
      state_key: params[:state]
    ).call
  end

  def flash_and_redirect(key, message)
    flash[key] = message
    redirect_to crime_application_path(params[:crime_application_id])
  end
end
