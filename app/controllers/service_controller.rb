class ServiceController < ApplicationController
  before_action :require_service_user!

  private

  # Users that can manage others are only allowed to access the Service on staging.
  # This is configured by the allow_user_managers_service_access feature flag.
  def require_service_user!
    return if current_user.service_user?
    return if FeatureFlags.allow_user_managers_service_access.enabled?

    redirect_to admin_manage_users_root_path
  end
end
