module Authorising
  class ChangeRole < Command
    attribute :user_manager_id, Types::Uuid
    attribute :from, Types::UserRole
    attribute :to, Types::UserRole

    def call # rubocop:disable Metrics/AbcSize
      raise User::CannotChangeRole, t(:unchangeable) unless user.can_change_role?
      raise User::CannotChangeRole, t(:illegal) if user.id == user_manager_id
      raise User::CannotChangeRole, t(:same) if from == to

      user.transaction do
        user.role = to
        user.save!

        publish_event!
      end
    end

    private

    def event
      RoleChanged.new(data: { user_id:, user_manager_id:, from:, to: })
    end

    def t(key)
      I18n.t(key, scope: [:manage_users, :exceptions, :commands, :change_role])
    end
  end
end
