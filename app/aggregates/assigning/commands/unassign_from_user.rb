module Assigning
  class UnassignFromUser < Command
    attribute :user_id, Types::Uuid
    attribute :from_whom_id, Types::Uuid

    def call
      with_assignment do |assignment|
        assignment.unassign_from_user(user_id:, from_whom_id:)
      end
    end
  end
end
