module Assigning
  class Assignment
    include AggregateRoot

    def initialize(id)
      @id = id
      @state = :unassigned
      @assignee_id = nil
    end

    attr_reader :id, :assignee_id

    def assign_to_user(user_id:, to_whom_id:)
      raise StateHasChanged unless assignee_id.nil?

      data = {
        assignment_id: id, user_id: user_id, to_whom_id: to_whom_id
      }

      apply AssignedToUser.new(data:)
    end

    def reassign_to_user(user_id:, from_whom_id:, to_whom_id:)
      raise StateHasChanged unless assignee_id == from_whom_id

      data = {
        assignment_id: id,
        user_id: user_id,
        from_whom_id: from_whom_id,
        to_whom_id: to_whom_id
      }

      apply ReassignedToUser.new(data:)
    end

    def unassign_from_user(user_id:, from_whom_id:)
      raise StateHasChanged unless assignee_id == from_whom_id

      data = {
        assignment_id: id, user_id: user_id, from_whom_id: from_whom_id
      }

      apply UnassignedFromUser.new(data:)
    end

    on AssignedToUser do |event|
      @assignee_id = event.data.fetch(:to_whom_id)
      @state = :assigned
    end

    on ReassignedToUser do |event|
      @assignee_id = event.data.fetch(:to_whom_id)
      @state = :assigned
    end

    on UnassignedFromUser do |_event|
      @assignee_id = nil
      @state = :unassigned
    end
  end
end
