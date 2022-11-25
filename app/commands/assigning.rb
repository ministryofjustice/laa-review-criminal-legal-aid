module Assigning
  StateHasChanged = Class.new(StandardError)

  class Command < Dry::Struct
    attribute :crime_application_id, Types::Uuid

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

    alias aggregate_id crime_application_id
  end

  class AssignToUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :user_name, Types::String
    attribute :to_whom_id, Types::Uuid
    attribute :to_whom_name, Types::String

    def call
      publish(AssignedToUser, data: to_hash)
    end
  end

  class AssignToSelf < Assigning::Command
    attribute :user, Types.Instance(User)

    def call
      AssignToUser.new(
        crime_application_id: crime_application_id,
        user_id: user.id,
        user_name: user.name,
        to_whom_id: user.id,
        to_whom_name: user.name
      ).call
    end
  end

  class ReassignToSelf < Assigning::Command
    attribute :user, Types.Instance(User)
    attribute :state_key, Types::String

    def call
      validate_state

      ReassignToUser.new(
        crime_application_id: crime_application_id,
        user_id: user.id,
        user_name: user.name,
        from_whom_id: current_assignment.user_id,
        from_whom_name: current_assignment.user_name,
        to_whom_id: user.id,
        to_whom_name: user.name
      ).call
    end

    private

    def current_assignment
      @current_assignment ||= CurrentAssignment.new(
        crime_application_id:
      )
    end

    def validate_state
      raise StateHasChanged if state_changed?
    end

    def state_changed?
      state_key != current_assignment.state_key
    end
  end

  class ReassignToUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :user_name, Types::String
    attribute :from_whom_id, Types::Uuid
    attribute :from_whom_name, Types::String
    attribute :to_whom_id, Types::Uuid
    attribute :to_whom_name, Types::String

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
        crime_application_id: crime_application_id,
        user_id: user.id,
        user_name: user.name,
        from_whom_id: user.id,
        from_whom_name: user.name
      ).call
    end
  end

  class UnassignFromUser < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :user_name, Types::String
    attribute :from_whom_id, Types::Uuid
    attribute :from_whom_name, Types::String

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
