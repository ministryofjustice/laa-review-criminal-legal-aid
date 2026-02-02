module Assigning
  class ReassignToUser < Command
    attribute :user_id, Types::Uuid
    attribute :from_whom_id, Types::Uuid
    attribute :to_whom_id, Types::Uuid
    attribute :reference, Types::ApplicationReference

    def call
      with_assignment do |assignment|
        assignment.reassign_to_user(user_id:, from_whom_id:, to_whom_id:, reference:)
      end
    end
  end
end
