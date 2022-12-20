module CurrentAssignments
  require_relative '../../aggregates/assigning'

  class Configuration
    def call(event_store)
      @event_store = event_store

      subscribe_and_link_to_stream(
        ->(event) { create_or_replace_assignee(event) },
        [Assigning::AssignedToUser, Assigning::ReassignedToUser]
      )

      subscribe_and_link_to_stream(
        ->(event) { unassign(event) },
        [Assigning::UnassignedFromUser]
      )
    end

    private

    def subscribe_and_link_to_stream(handler, events)
      link_and_handle = lambda do |event|
        link_to_stream(event)
        handler.call(event)
      end

      subscribe(link_and_handle, events)
    end

    def subscribe(handler, events)
      @event_store.subscribe(handler, to: events)
    end

    def link_to_stream(event)
      link_event_to_stream(event, 'Assigning$all')
    end

    def link_event_to_stream(event, stream, expected_version: :any)
      @event_store.link(
        event.event_id,
        stream_name: stream,
        expected_version: expected_version
      )
    end

    # TODO: extract handlers
    def create_or_replace_assignee(event)
      user_id = event.data.fetch(:to_whom_id)
      assignment_id = event.data.fetch(:assignment_id)

      CurrentAssignment.upsert(
        { assignment_id:, user_id: },
        unique_by: :assignment_id
      )
    end

    def unassign(event)
      user_id = event.data.fetch(:from_whom_id)
      assignment_id = event.data.fetch(:assignment_id)

      CurrentAssignment.where(assignment_id:, user_id:).delete_all
    end
  end
end
