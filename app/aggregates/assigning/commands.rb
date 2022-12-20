module Assigning
  StateHasChanged = Class.new(StandardError)

  class AssignToUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :to_whom_id, Types::Uuid

    def call
      with_assignment do |assignment|
        assignment.assign_to_user(user_id:, to_whom_id:)
      end
    end
  end

  class ReassignToUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :from_whom_id, Types::Uuid
    attribute :to_whom_id, Types::Uuid

    def call
      with_assignment do |assignment|
        assignment.reassign_to_user(user_id:, from_whom_id:, to_whom_id:)
      end
    end
  end

  class UnassignFromUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :from_whom_id, Types::Uuid

    def call
      with_assignment do |assignment|
        assignment.unassign_from_user(user_id:, from_whom_id:)
      end
    end
  end
end
