module Assigning
  class AssignToUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :to_whom_id, Types::Uuid

    def call
      publish(AssignedToUser, data: to_hash)
    end
  end

  class ReassignToUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :from_whom_id, Types::Uuid
    attribute :to_whom_id, Types::Uuid

    def call
      publish(
        ReassignedToUser, data: to_hash
      )
    end
  end

  class UnassignFromUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :from_whom_id, Types::Uuid

    def call
      publish(
        UnassignedFromUser,
        data: to_hash
      )
    end
  end
end
