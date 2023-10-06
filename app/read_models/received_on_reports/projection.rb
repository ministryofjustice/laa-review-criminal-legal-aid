module ReceivedOnReports
  class Projection
    def initialize(stream_names:, observed_at: Time.current)
      @stream_names = stream_names.uniq
      @observed_at = observed_at
    end

    attr_reader :observed_at

    def dataset
      return @dataset if @dataset

      total_received = 0
      total_closed = 0

      @stream_names.each do |stream_name|
        scope = scope(stream_name)
        total_received += scope.of_type(Configuration::OPENING_EVENTS).count
        total_closed += scope.of_type(Configuration::CLOSING_EVENTS).count
      end

      @dataset = { total_received:, total_closed: }
    end

    private

    def scope(stream_name)
      Rails.application.config.event_store.read.stream(stream_name)
           .older_than_or_equal(observed_at)
    end

    class << self
      def for_dates(business_days, observed_at: nil)
        stream_names = [*business_days].map { |day| business_day_stream_name(day) }
        new(stream_names:, observed_at:)
      end

      def business_day_stream_name(business_day)
        business_day.strftime(ReceivedOnReports::Configuration::STREAM_NAME_FORMAT)
      end
    end
  end
end
