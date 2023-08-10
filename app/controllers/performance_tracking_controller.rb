class PerformanceTrackingController < ServiceController
  before_action :require_supervisor!

  def index
    @caseworker_report = Reporting::CaseworkerReport.new
  end

  private

  # Users that can manage others can access this on staging for testing purposes.
  def require_supervisor!
    return if current_user.service_user_supervisor?
    return if allow_user_managers_service_access? && current_user.user_manager_supervisor?

    render status: :not_found, template: 'errors/not_found', layout: 'errors'
    false
  end
end
