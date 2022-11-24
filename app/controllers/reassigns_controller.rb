class ReassignsController < ApplicationController
  def new
    @current_assignment = CurrentAssignment.new(
      crime_application_id: params[:crime_application_id]
    )

    return if @current_assignment&.assigned?

    raise ApiResource::NotFound, 'Not Found'
  end

  def create
    Assigning::ReassignToSelf.new(
      crime_application_id: params[:crime_application_id],
      user: current_user,
      state_key: params[:state]
    ).call
  rescue Assigning::StateHasChanged
    flash[:important] = :state_has_changed
  else
    flash[:success] = :assigned_to_self
  ensure
    redirect_to crime_application_path(params[:crime_application_id])
  end
end
