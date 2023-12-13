module ReceivedOnReports
  class Projection
    def initialize(stream_name:, observed_at: Time.current)
      @stream_name = stream_name
      @observed_at = observed_at
    end

    attr_reader :observed_at

    def dataset
      @dataset ||= load_from_events
    end

    private

    def load_from_events # rubocop:disable  Metrics
      scope.init(-> { initial_row })
           .when(
             OPENING_EVENTS,
             lambda { |rows, event|
               next if event.timestamp > observed_at

               work_stream = event.data.fetch(:work_stream, default_work_stream)

               application_streams[event.data.fetch(:application_id)] = work_stream
               rows[work_stream].receive
             }
           )
           .when(
             CLOSING_EVENTS,
             lambda { |rows, event|
               next if event.timestamp > observed_at

               work_stream = application_streams[event.data.fetch(:application_id)]

               if event.timestamp >= start_of_observed_business_day
                 rows[work_stream].close_on_observed_business_day
               else
                 rows[work_stream].close_before_observed_business_day
               end
             }
           )
           .run(Rails.application.config.event_store)
    end

    def scope
      RailsEventStore::Projection.from_stream(@stream_name)
    end

    def initial_row
      Types::WorkStreamType.values.index_with { |work_stream| Row.new(work_stream:) }
    end

    # temporary hash map of {'application_id' => 'work_stream'}
    def application_streams
      @application_streams ||= {}
    end

    def start_of_observed_business_day
      @start_of_observed_business_day ||= BusinessDay.new(day_zero: observed_at).starts_on
    end

    # Assume that events stored without a work_stream are old and therefore CAT 1
    def default_work_stream
      Types::WorkStreamType['criminal_applications_team']
    end

    class << self
      def for_date(date, observed_at: nil)
        stream_name = ReceivedOnReports.stream_name(date)
        new(stream_name:, observed_at:)
      end
    end
  end
end
