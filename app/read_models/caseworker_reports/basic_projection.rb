module CaseworkerReports
  class BasicProjection
    def initialize(stream_name:)
      @stream_name = stream_name
    end

    def dataset
      @dataset ||= load_from_events
    end

    def load_from_events # rubocop:disable  Metrics
      event_store = Rails.application.config.event_store
      RubyEventStore::Projection
        .init(Hash.new)
        .on(Assigning::AssignedToUser) { |rows, event|
          user_id = event.data.fetch(:to_whom_id)
          rows[user_id] ||= Row.new(user_id)
          rows[user_id].assign
          rows
        }
        .on(Assigning::ReassignedToUser) { |rows, event|
          user_id = event.data.fetch(:to_whom_id)
          rows[user_id] ||= Row.new(user_id)
          rows[user_id].reassign_to

          user_id = event.data.fetch(:from_whom_id)
          rows[user_id] ||= Row.new(user_id)
          rows[user_id].reassign_from
          rows
        }
        .on(Assigning::UnassignedFromUser) { |rows, event|
          user_id = event.data.fetch(:from_whom_id)
          rows[user_id] ||= Row.new(user_id)
          rows[user_id].unassign
          rows
        }
        .on(Reviewing::SentBack) { |rows, event|
          user_id = event.data.fetch(:user_id)
          rows[user_id] ||= Row.new(user_id)
          rows[user_id].send_back
          rows
        }
        .on(Reviewing::Completed) { |rows, event|
          user_id = event.data.fetch(:user_id)
          rows[user_id] ||= Row.new(user_id)
          rows[user_id].complete
          rows
        }
        .call(event_store.read.stream(@stream_name))
    end
  end
end
