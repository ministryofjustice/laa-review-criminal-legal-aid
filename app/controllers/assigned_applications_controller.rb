class AssignedApplicationsController < ApplicationController
  before_action :set_assigned_application, except: [:index, :create, :next_application]

  def index
    @applications = current_user.assigned_applications
  end

  def create
    Assigning::AssignToSelf.new(
      crime_application_id: params[:crime_application_id],
      user: current_user
    ).call

    flash[:success] = :assigned_to_self

    redirect_to crime_application_path(
      id: params[:crime_application_id]
    )
  end

  def next_application
    filter = ApplicationSearchFilter.new({ assigned_user_id: CurrentAssignment::UNASSIGNED_USER.id })
    search = ApplicationSearch.new(filter:)

    next_app_id = search.applications.first&.id

    if next_app_id
      Assigning::AssignToSelf.new(crime_application_id: next_app_id, user: current_user).call

      redirect_to crime_application_path(id: next_app_id)
    else
      flash[:important] = :no_next_to_assign

      redirect_to assigned_applications_path
    end
  end

  def destroy
    Assigning::UnassignFromSelf.new(
      crime_application_id: params[:id],
      user: current_user
    ).call

    flash[:success] = :unassigned_from_self

    redirect_to assigned_applications_path
  end

  private

  def set_assigned_application
    @assigned_application = current_user.assigned_applications.find { |aa| aa.id == params[:id] }

    raise ApiResource::RoutingError, 'Not Found' unless @assigned_application
  end
end
