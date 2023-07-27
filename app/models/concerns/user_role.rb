module UserRole
  extend ActiveSupport::Concern

  included do
    # Note mapping to PostgreSQL enum type
    enum role: {
      caseworker: 'caseworker',
      supervisor: 'supervisor',
      user_manager: 'user_manager'
    }

    attribute :can_manage_others, :boolean, default: false
  end

  def can_manage_others=(value)
    if value
      self[:role] = 'user_manager'
    else
      self[:role] = 'caseworker'
    end
  end

  def can_manage_others?
    user_manager?
  end
end
