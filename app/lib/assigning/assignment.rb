module Assigning
  class Assignment
    include AggregateRoot

    def initialize(id)
      @id = id
      @state = :unassigned
    end

    attr_reader :id

    def assign_to_self(user_id)
      Assigning::AssignToUser.new(
        assignment_id: id,
        user_id: user_id,
        to_whom_id: user_id
      ).call
    end

    def unassign_from_self(user_id)
      Assigning::UnassignFromUser.new(
        assignment_id: id,
        user_id: user_id,
        from_whom_id: user_id
      ).call
    end
  end
end
