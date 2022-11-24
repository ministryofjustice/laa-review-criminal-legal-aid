class AssignedApplicationsController < ApplicationController
  before_action :set_assigned_application, except: [:index, :create]

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
