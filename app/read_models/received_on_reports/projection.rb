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

               data = event.data.slice(:work_stream, :application_type)
               applications[event.data.fetch(:application_id)] = data

               rows[data.fetch(:work_stream)][data[:application_type]].receive
             }
           )
           .when(
             CLOSING_EVENTS,
             lambda { |rows, event|
               next if event.timestamp > observed_at

               data = applications[event.data.fetch(:application_id)]
               row = rows[data.fetch(:work_stream)][data[:application_type]]

               if event.timestamp >= start_of_observed_business_day
                 row.close_on_observed_business_day
               else
                 row.close_before_observed_business_day
               end
             }
           )
           .run(Rails.application.config.event_store)
    end

    def scope
      RailsEventStore::Projection.from_stream(@stream_name)
    end

    def initial_row
      Types::WorkStreamType.values.index_with do |work_stream|
        {
          Types::ApplicationType['initial'] =>  Row.new(work_stream:),
          Types::ApplicationType['post_submission_evidence'] => Row.new(work_stream:)
        }
      end
    end

    # Temporary hash map of:
    # { id => { work_stream: 'cat1', application_type: 'initial'} }
    #
    def applications
      @applications ||= {}
    end

    def start_of_observed_business_day
      @start_of_observed_business_day ||= BusinessDay.new(day_zero: observed_at).starts_on
    end

    class << self
      def for_date(date, observed_at: nil)
        stream_name = ReceivedOnReports.stream_name(date)
        new(stream_name:, observed_at:)
      end
    end
  end
end
