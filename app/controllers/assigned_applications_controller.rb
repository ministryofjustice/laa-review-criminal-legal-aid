class AssignedApplicationsController < ApplicationController
  def index
    filter = ApplicationSearchFilter.new(assigned_status: current_user_id)
    search = ApplicationSearch.new(filter:)

    @applications = search.results
  end

  def create
    Assigning::AssignToUser.new(
      assignment_id: params[:crime_application_id],
      user_id: current_user_id,
      to_whom_id: current_user_id
    ).call

    flash[:success] = :assigned_to_self

    redirect_to crime_application_path(
      id: params[:crime_application_id]
    )
  end

  def next_application
    filter = ApplicationSearchFilter.new(assigned_status: 'unassigned')
    search = ApplicationSearch.new(filter:)
    next_app_id = search.results.first&.id

    if next_app_id
      Assigning::AssignToUser.new(
        assignment_id: next_app_id, user_id: current_user_id, to_whom_id: current_user_id
      ).call

      redirect_to crime_application_path(id: next_app_id)
    else
      flash[:important] = :no_next_to_assign

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
      from_whom_id: current_user_id
    ).call

    flash[:success] = :unassigned_from_self

    redirect_to assigned_applications_path
  end
end
