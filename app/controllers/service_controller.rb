class ServiceController < ApplicationController
  before_action :require_service_user!

  private

  # UserManagers are only allowed to access the Service on staging.
  def require_service_user!
    return if FeatureFlags.allow_user_managers_service_access.enabled?
    return unless current_user.can_manage_others?

    redirect_to admin_manage_users_path
  end
end
