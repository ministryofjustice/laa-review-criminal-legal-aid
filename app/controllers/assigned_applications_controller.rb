class AssignedApplicationsController < ApplicationController
  before_action :set_assigned_application, except: [:index, :create, :get_next]

  def index
    current_assignments = current_user.current_assignments

    @applications = current_assignments.pluck(:assignment_id).map { |a_id| CrimeApplication.find(a_id) }
  end

  def create
    Assigning::AssignToSelf.new(
      assignment_id: params[:crime_application_id],
      user: current_user
    ).call

    flash[:success] = :assigned_to_self

    redirect_to crime_application_path(
      id: params[:crime_application_id]
    )
  end

  # rubocop:disable Naming/AccessorMethodName, Metrics/MethodLength, Metrics/AbcSize
  def get_next
    filter = ApplicationSearchFilter.new(
      {
        assigned_user_id: CurrentAssignment::UNASSIGNED_USER.id
      }
    )
    search = ApplicationSearch.new(filter:)

    next_app_id = search.applications.first&.id

    if next_app_id
      Assigning::AssignToSelf.new(
        assignment_id: next_app_id,
        user: current_user
      ).call

      flash[:success] = :assigned_to_self

      redirect_to crime_application_path(
        id: next_app_id
      )
    else
      flash[:important] = :no_next_to_assign

      redirect_to assigned_applications_path
    end
  end
  # rubocop:enable Naming/AccessorMethodName, Metrics/MethodLength, Metrics/AbcSize

  def destroy
    Assigning::UnassignFromSelf.new(
      assignment_id: params[:id],
      user: current_user
    ).call

    flash[:success] = :unassigned_from_self

    redirect_to assigned_applications_path
  end

  private

  def set_assigned_application
    @assigned_application = current_user.current_assignments.find_by(
      assignment_id: params[:id]
    )
  end
end
