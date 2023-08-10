module UserReports
  extend ActiveSupport::Concern

  def reports
    return Types::Report.values if user_manager? && FeatureFlags.allow_user_managers_service_access.enabled?
    return [] if user_manager?

    Types::USER_ROLE_REPORTS.fetch(role)
  end

  # Determines whether a user has permission to access the reporting dashboard (Reports#index).
  # By default, caseworkers can access their reports, but they are not presented with the full
  # reporting dashboard and navigation.
  def can_access_reporting_dashboard?
    return true if supervisor?
    return true if user_manager? && FeatureFlags.allow_user_managers_service_access.enabled?

    false
  end
end
