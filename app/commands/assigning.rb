module Assigning
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

    def call
      publish(
        Assigning::AssignedToUser,
        data: {
          user_id:,
          user_name:,
          crime_application_id:
        }
      )
    end
  end

  class UnassignFromSelf < Assigning::Command
    attribute :user_id, Types::Uuid
    attribute :user_name, Types::String

    def call
      publish(
        Assigning::UnassignedFromSelf,
        data: {
          user_id:,
          user_name:,
          crime_application_id:
        }
      )
    end
  end

  class AssignedToUser < RailsEventStore::Event
  end

  class UnassignedFromSelf < RailsEventStore::Event
  end
end
