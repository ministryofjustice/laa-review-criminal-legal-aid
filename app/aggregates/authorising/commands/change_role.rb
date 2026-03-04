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
        if [UserRole::AUDITOR, UserRole::DATA_ANALYST].include?(to)
          unassign_reviews_from_user
          clear_competencies
        end
        user.save!
        publish_event!
      end
    end

    private

    def clear_competencies
      Allocating::SetCompetencies.call(
        user: user,
        by_whom: User.active.find(user_manager_id),
        competencies: []
      )
    end

    def unassign_reviews_from_user
      user.current_assignments.each do |assignment|
        Assigning::UnassignFromUser.new(
          assignment_id: assignment.assignment_id,
          user_id: user_manager_id,
          from_whom_id: user.id,
          reference: CrimeApplication.find(assignment.assignment_id).reference
        ).call
      end
    end

    def event
      RoleChanged.new(data: { user_id:, user_manager_id:, from:, to: })
    end

    def t(key)
      I18n.t(key, scope: [:manage_users, :exceptions, :commands, :change_role])
    end
  end
end
