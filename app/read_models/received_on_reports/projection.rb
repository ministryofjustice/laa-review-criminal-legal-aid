module ReceivedOnReports
  class Projection
    def initialize(stream_name:, observed_at: Time.current)
      @stream_name = stream_name
      @observed_at = observed_at
    end

    attr_reader :observed_at

    def dataset
      return @dataset if @dataset

      total_received = scope.of_type(Configuration::OPENING_EVENTS).count
      total_closed = scope.of_type(Configuration::CLOSING_EVENTS).count

      @dataset = { total_received:, total_closed: }
    end

    private

    def scope
      Rails.application.config.event_store.read.stream(@stream_name)
           .older_than_or_equal(observed_at)
    end

    class << self
      def for_date(business_day, observed_at: nil)
        stream_name = business_day.strftime(
          ReceivedOnReports::Configuration::STREAM_NAME_FORMAT
        )

        new(stream_name:, observed_at:)
      end
    end
  end
end
