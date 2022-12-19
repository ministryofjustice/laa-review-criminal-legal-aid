class AssignToUser < Assigning::Command
  attribute :user_id, Types::Uuid
  attribute :to_whom_id, Types::Uuid

  def call
    publish(AssignedToUser, data: to_hash)
  end
end

