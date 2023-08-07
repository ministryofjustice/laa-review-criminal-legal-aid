class PerformanceTrackingController < ServiceController
  before_action :require_supervisor!

  def index; end

  private

  def require_supervisor!
    return if current_user.supervisor? && FeatureFlags.basic_user_roles.enabled?

    render status: :not_found, template: 'errors/not_found', layout: 'errors'
    false
  end
end
