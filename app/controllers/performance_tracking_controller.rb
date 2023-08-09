class PerformanceTrackingController < ServiceController
  before_action :require_supervisor!

  def index; end

  private

  # Users that can manage others can access this on staging for testing purposes.
  def require_supervisor!
    return if current_user.supervisor? && FeatureFlags.basic_user_roles.enabled?
    return if allow_user_managers_service_access?

    render status: :not_found, template: 'errors/not_found', layout: 'errors'
    false
  end
end
