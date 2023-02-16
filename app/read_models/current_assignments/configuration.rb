module CurrentAssignments
  class Configuration
    def call(event_store)
      @event_store = event_store

      subscribe(
        ->(event) { create_or_replace_assignee(event) },
        [Assigning::AssignedToUser, Assigning::ReassignedToUser]
      )

      subscribe(
        ->(event) { unassign(event) },
        [Assigning::UnassignedFromUser, Reviewing::SentBack, Reviewing::Completed]
      )
    end

    private

    def subscribe(handler, events)
      @event_store.subscribe(handler, to: events)
    end

    def create_or_replace_assignee(event)
      user_id = event.data.fetch(:to_whom_id)
      assignment_id = event.data.fetch(:assignment_id)

      CurrentAssignment.upsert(
        { assignment_id:, user_id: },
        unique_by: :assignment_id
      )
    end

    def unassign(event)
      user_id = event.data.slice(:from_whom_id, :user_id).compact.first

      assignment_id = event.data.slice(:assignment_id, :application_id).compact.first

      CurrentAssignment.where(assignment_id:, user_id:).delete_all
    end
  end
end
