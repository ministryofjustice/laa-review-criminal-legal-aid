module UserRole
  extend ActiveSupport::Concern

  # Deliberately duplicate constant names for use in
  # permissions checks for brevity and explicitness
  CASEWORKER = Types::CASEWORKER_ROLE
  SUPERVISOR = Types::SUPERVISOR_ROLE
  DATA_ANALYST = Types::DATA_ANALYST_ROLE

  included do
    # NOTE: mapping to PostgreSQL enum type via dry-types definition
    enum role: Types::UserRole.mapping
  end

  def can_read_application?
    [CASEWORKER, SUPERVISOR].include?(role)
  end

  def can_write_application?
    [SUPERVISOR].include?(role)
  end

  # Determines whether a user has permission to access the reporting dashboard (Reports#index).
  # By default, caseworkers can access their reports, but they are not presented with the full
  # reporting dashboard and navigation.
  def can_access_reporting_dashboard?
    return true if reporting_user?
    return true if user_manager? && FeatureFlags.allow_user_managers_service_access.enabled?

    false
  end

  # TODO: Any reason to not allow supervisor to be 'downgraded' to caseworker?
  def can_change_role?
    return false unless activated?
    return false if deactivated?
    return false if dormant?

    FeatureFlags.basic_user_roles.enabled?
  end

  def service_user?
    return true if can_manage_others? && FeatureFlags.allow_user_managers_service_access.enabled?

    [CASEWORKER, SUPERVISOR].include?(role) && !can_manage_others?
  end

  def reporting_user?
    [SUPERVISOR, DATA_ANALYST].include?(role) && !can_manage_others?
  end

  def user_manager?
    can_manage_others?
  end

  def available_roles
    Types::USER_ROLES - [role]
  end

  def reports
    return Types::Report.values if user_manager? && FeatureFlags.allow_user_managers_service_access.enabled?
    return [] if user_manager?

    Types::USER_ROLE_REPORTS.fetch(role)
  end
end
