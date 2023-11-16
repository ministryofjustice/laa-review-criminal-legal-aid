module CaseworkerReports
  class Projection
    def initialize(stream_name:)
      @scope = RailsEventStore::Projection.from_stream(stream_name)
    end

    def dataset
      @dataset ||= load_from_events
    end

    def load_from_events # rubocop:disable  Metrics
      @scope.init(-> { {} })
            .when(
              Assigning::AssignedToUser,
              lambda { |rows, event|
                user_id = event.data.fetch(:to_whom_id)
                rows[user_id] ||= Row.new(user_id)
                rows[user_id].assign
              }
            )
            .when(
              Assigning::ReassignedToUser,
              lambda { |rows, event|
                user_id = event.data.fetch(:to_whom_id)
                rows[user_id] ||= Row.new(user_id)
                rows[user_id].reassign_to

                user_id = event.data.fetch(:from_whom_id)
                rows[user_id] ||= Row.new(user_id)
                rows[user_id].reassign_from
              }
            )
            .when(
              Assigning::UnassignedFromUser,
              lambda { |rows, event|
                user_id = event.data.fetch(:from_whom_id)
                rows[user_id] ||= Row.new(user_id)
                rows[user_id].unassign
              }
            )
            .when(
              Reviewing::SentBack,
              lambda { |rows, event|
                user_id = event.data.fetch(:user_id)
                rows[user_id] ||= Row.new(user_id)
                rows[user_id].send_back
              }
            )
            .when(
              Reviewing::Completed,
              lambda { |rows, event|
                user_id = event.data.fetch(:user_id)
                rows[user_id] ||= Row.new(user_id)
                rows[user_id].complete
              }
            )
            .run(Rails.application.config.event_store)
    end
  end
end
