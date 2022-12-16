module Assigning
  StateHasChanged = Class.new(StandardError)

  class Command < Dry::Struct
    attribute :assignment_id, Types::Uuid

    def publish(event_klass, args)
      event_store.publish(
        event_klass.new(**args),
        stream_name:
      )
    end

    def event_store
      Rails.configuration.event_store
    end

    def stream_name
      "Assigning$#{aggregate_id}"
    end

    alias aggregate_id assignment_id
  end

  class AssignToUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :to_whom_id, Types::Uuid

    def call
      publish(AssignedToUser, data: to_hash)
    end
  end

  class AssignToSelf < Assigning::Command
    attribute :user, Types.Instance(User)

    def call
      AssignToUser.new(
        assignment_id: assignment_id,
        user_id: user.id,
        to_whom_id: user.id
      ).call
    end
  end

  class ReassignToSelf < Assigning::Command
    attribute :user, Types.Instance(User)
    attribute :state_key, Types::String

    def call
      raise StateHasChanged if state_changed?

      ReassignToUser.new(
        assignment_id: assignment_id,
        user_id: user.id,
        from_whom_id: current_assignment.user_id,
        to_whom_id: user.id
      ).call
    end

    private

    def current_assignment
      @current_assignment ||= CurrentAssignment.new(
        assignment_id:
      )
    end

    def state_changed?
      state_key != current_assignment.state_key
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

  class UnassignFromSelf < Assigning::Command
    attribute :user, Types.Instance(User)

    def call
      UnassignFromUser.new(
        assignment_id: assignment_id,
        user_id: user.id,
        from_whom_id: user.id
      ).call
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

  class AssignedToUser < RailsEventStore::Event
  end

  class UnassignedFromUser < RailsEventStore::Event
  end

  class ReassignedToUser < RailsEventStore::Event
  end
end
