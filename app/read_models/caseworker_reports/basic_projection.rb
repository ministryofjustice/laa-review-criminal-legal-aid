module CaseworkerReports
  class BasicProjection
    def initialize(stream_name:)
      @stream_name = stream_name
    end

    def dataset
      @dataset ||= load_from_events
    end

    def load_from_events
      event_store = Rails.application.config.event_store
      projection = build_projection
      projection.call(event_store.read.stream(@stream_name))
    end

    private

    def build_projection # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      projection = RubyEventStore::Projection.init({})
      projection.on(Assigning::AssignedToUser) do |rows, event|
        user_id = event.data.fetch(:to_whom_id)
        rows[user_id] ||= Row.new(user_id)
        rows[user_id].assign
        rows
      end
      projection.on(Assigning::ReassignedToUser) do |rows, event|
        user_id = event.data.fetch(:to_whom_id)
        rows[user_id] ||= Row.new(user_id)
        rows[user_id].reassign_to

        user_id = event.data.fetch(:from_whom_id)
        rows[user_id] ||= Row.new(user_id)
        rows[user_id].reassign_from
        rows
      end
      projection.on(Assigning::UnassignedFromUser) do |rows, event|
        user_id = event.data.fetch(:from_whom_id)
        rows[user_id] ||= Row.new(user_id)
        rows[user_id].unassign
        rows
      end
      projection.on(Reviewing::SentBack) do |rows, event|
        user_id = event.data.fetch(:user_id)
        rows[user_id] ||= Row.new(user_id)
        rows[user_id].send_back
        rows
      end
      projection.on(Reviewing::Completed) do |rows, event|
        user_id = event.data.fetch(:user_id)
        rows[user_id] ||= Row.new(user_id)
        rows[user_id].complete
        rows
      end
      projection
    end
  end
end
