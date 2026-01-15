module UserRole
  extend ActiveSupport::Concern

  # Deliberately duplicate constant names for use in
  # permissions checks for brevity and explicitness
  CASEWORKER = Types::CASEWORKER_ROLE
  SUPERVISOR = Types::SUPERVISOR_ROLE
  DATA_ANALYST = Types::DATA_ANALYST_ROLE
  AUDITOR = Types::AUDITOR_ROLE
  REPORTING_ROLES = [SUPERVISOR, DATA_ANALYST].freeze
  SERVICE_USERS = [CASEWORKER, SUPERVISOR, DATA_ANALYST, AUDITOR].freeze

  included do
    # NOTE: mapping to PostgreSQL enum type via dry-types definition
    enum :role, Types::UserRole.mapping
  end

  # Determines whether a user has permission to access the reporting dashboard (Reports#index).
  # By default, caseworkers can access their reports, but they are not presented with the full
  # reporting dashboard and navigation.
  def can_access_reporting_dashboard?
    reporting_user? || user_manager_with_service_access?
  end

  def can_download_reports?
    role == DATA_ANALYST
  end

  def can_change_role?
    activated? && !deactivated? && !dormant?
  end

  def service_user?
    user_manager_with_service_access? || (role_in?(SERVICE_USERS) && non_manager?)
  end

  def reporting_user?
    role_in?(REPORTING_ROLES) && non_manager?
  end

  def admin?
    can_manage_others?
  end

  def readonly_user?
    role == AUDITOR && non_manager?
  end

  def available_roles
    Types::USER_ROLES - [role]
  end

  def user_manager?
    can_manage_others?
  end

  def reports
    return Types::Report.values if user_manager_with_service_access?
    return [] if user_manager? || readonly_user?

    Types::USER_ROLE_REPORTS.fetch(role)
  end

  private

  def user_manager_with_service_access?
    user_manager? && FeatureFlags.allow_user_managers_service_access.enabled?
  end

  def non_manager?
    !can_manage_others?
  end

  def role_in?(roles)
    roles.include?(role)
  end
end
