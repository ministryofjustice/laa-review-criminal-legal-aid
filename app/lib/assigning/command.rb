module Assigning
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
end
