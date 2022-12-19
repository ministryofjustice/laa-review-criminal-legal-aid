module Assigning
  class AssignToUser < Command
    attribute :user_id, Types::Uuid
    attribute :to_whom_id, Types::Uuid

    def call
      with_assignment do |assignment|
        assignment.assign_to_user(user_id:, to_whom_id:)
      end
    end
  end
end
