module UserRole
  extend ActiveSupport::Concern

  # Deliberately duplicate constant names for use in
  # permissions checks for brevity and explicitness
  CASEWORKER = Types::CASEWORKER_ROLE
  SUPERVISOR = Types::SUPERVISOR_ROLE
  DATA_ANALYST = Types::DATA_ANALYST_ROLE
  AUDITOR = Types::AUDITOR_ROLE
  BUSINESS_SUPPORT = Types::BUSINESS_SUPPORT_ROLE
  REPORTING_ROLES = [SUPERVISOR, DATA_ANALYST, AUDITOR, BUSINESS_SUPPORT].freeze
  SERVICE_USERS = [CASEWORKER, SUPERVISOR, DATA_ANALYST, AUDITOR, BUSINESS_SUPPORT].freeze
  COMPETENCY_MANAGER_ROLES = [SUPERVISOR, BUSINESS_SUPPORT].freeze

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
    role_in?([DATA_ANALYST, AUDITOR, BUSINESS_SUPPORT])
  end

  # Determines whether a user can manage user competencies.
  def can_manage_competencies?
    role_in?(COMPETENCY_MANAGER_ROLES)
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

  def available_roles
    Types::USER_ROLES - [role]
  end

  def user_manager?
    can_manage_others?
  end

  def reports
    return Types::Report.values if user_manager_with_service_access?
    return [] if user_manager?

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
