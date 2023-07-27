module Capable
  extend ActiveSupport::Concern

  included do
    # Note mapping to PostgreSQL enum type
    enum role: {
      caseworker: 'caseworker',
      supervisor: 'supervisor',
    }

    def can_read_application?
      %w[caseworker supervisor].include?(@role)
    end

    def can_write_application?
      %w[supervisor].include?(@role)
    end

    def service_user?
      %w[caseworker supervisor].include?(@role) && !can_manage_others?
    end

    def user_manager?
      can_manage_others?
    end

    def change_role_to
      @change_role_to ||= (%w[caseworker supervisor] - [role]).first.to_s
    end

    def change_role!
      self.role = change_role_to
      save!
    end

    # def role
    #   @role ||= UserRole.new(read_attribute(:role))
    # end
  end
end
