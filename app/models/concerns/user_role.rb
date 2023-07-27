module UserRole
  extend ActiveSupport::Concern

  included do
    # Note mapping to PostgreSQL enum type
    enum role: {
      caseworker: 'caseworker',
      supervisor: 'supervisor',
    }
  end
end
