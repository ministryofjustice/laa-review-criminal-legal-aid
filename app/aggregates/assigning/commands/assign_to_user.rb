module Assigning
  class AssignToUser < Command
    attribute :user_id, Types::Uuid
    attribute :to_whom_id, Types::Uuid
    attribute :reference, Types::ApplicationReference

    def call
      with_assignment do |assignment|
        assignment.assign_to_user(user_id:, to_whom_id:, reference:)
      end
    end
  end
end
