module Reporting
  class CaseworkerReport
    def initialize(stream_name: nil)
      @scope = if stream_name
                 RailsEventStore::Projection.from_stream(stream_name)
               else
                 RailsEventStore::Projection.from_all_streams
               end
    end

    def rows
      dataset.values.sort_by { |h| h[:user_name].upcase }
    end

    private

    def dataset
      @dataset ||= load_from_events
    end

    def load_from_events # rubocop:disable  Metrics
      @scope.init(-> { {} })
            .when(
              Assigning::AssignedToUser,
              lambda { |rows, event|
                user_id = event.data.fetch(:to_whom_id)
                rows[user_id] ||= initial_user_row(user_id)
                rows[user_id][:total_assigned_to_user] += 1
              }
            )
            .when(
              Assigning::ReassignedToUser,
              lambda { |rows, event|
                user_id = event.data.fetch(:to_whom_id)
                rows[user_id] ||= initial_user_row(user_id)
                rows[user_id][:total_assigned_to_user] += 1

                user_id = event.data.fetch(:from_whom_id)
                rows[user_id] ||= initial_user_row(user_id)
                rows[user_id][:total_unassigned_from_user] += 1
              }
            )
            .when(
              Assigning::UnassignedFromUser,
              lambda { |rows, event|
                user_id = event.data.fetch(:from_whom_id)
                rows[user_id] ||= initial_user_row(user_id)
                rows[user_id][:total_unassigned_from_user] += 1
              }
            )
            .when(
              Reviewing::SentBack,
              lambda { |rows, event|
                user_id = event.data.fetch(:user_id)
                rows[user_id] ||= initial_user_row(user_id)
                rows[user_id][:total_closed_by_user] += 1
              }
            )
            .when(
              Reviewing::Completed,
              lambda { |rows, event|
                user_id = event.data.fetch(:user_id)
                rows[user_id] ||= initial_user_row(user_id)
                rows[user_id][:total_closed_by_user] += 1
              }
            )
            .run(Rails.application.config.event_store)
    end

    # returns a hash of the initial row columns with values set to zero
    def initial_user_row(user_id)
      {
        user_name: User.name_for(user_id),
        total_assigned_to_user: 0,
        total_unassigned_from_user: 0,
        total_closed_by_user: 0
      }
    end

    class << self
      def for_temporal_period(date:, interval:)
        stream_name = date.strftime(
          CaseworkerReports::Configuration::STREAM_NAME_FORMATS.fetch(interval)
        )

        new(stream_name:)
      end
    end
  end
end
