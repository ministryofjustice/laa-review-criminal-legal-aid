class AssignedApplicationsController < ApplicationController
  def index
    @applications = current_user.assigned_applications
  end
end
