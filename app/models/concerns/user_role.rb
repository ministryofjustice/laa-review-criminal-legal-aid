module UserRole
  extend ActiveSupport::Concern

  # Deliberately duplicate constant names for use in
  # permissions checks for brevity and explicitness
  CASEWORKER = Types::CASEWORKER_ROLE
  SUPERVISOR = Types::SUPERVISOR_ROLE

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

  def service_user?
    [CASEWORKER, SUPERVISOR].include?(role) && !can_manage_others?
  end

  def user_manager?
    can_manage_others?
  end

  # TODO: Any reason to not allow supervisor to be 'downgraded' to caseworker?
  def can_change_role?
    return false if dormant?
    return false unless activated?

    FeatureFlags.basic_user_roles.enabled? && activated?
  end

  def toggle_role
    self.role = @toggle_role ||= ([CASEWORKER, SUPERVISOR] - [role]).first.to_s
  end
end
