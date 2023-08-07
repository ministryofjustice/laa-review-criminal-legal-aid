class PerformanceTrackingController < ServiceController
  before_action :require_supervisor!

  def index; end

  private

  # Users that can manage others are only allowed to access this page on staging.
  # This is configured by the allow_user_managers_service_access feature flag.
  def require_supervisor!
    return if current_user.supervisor? && FeatureFlags.basic_user_roles.enabled?
    return if FeatureFlags.allow_user_managers_service_access.enabled?

    render status: :not_found, template: 'errors/not_found', layout: 'errors'
    false
  end
end
