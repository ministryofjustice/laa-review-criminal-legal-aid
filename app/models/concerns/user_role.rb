module UserRole
  extend ActiveSupport::Concern

  included do
    # Note mapping to PostgreSQL enum type
    enum role: {
      caseworker: 'caseworker',
      supervisor: 'supervisor',
      user_manager: 'user_manager'
    }
  end
end
