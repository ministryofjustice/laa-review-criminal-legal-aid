module Reporting
  class VolumesReport
    def initialize(time_period:)
      @time_period = time_period
    end

    attr_reader :time_period

    # Currently only CAT3 applications are processed on Review.
    def rows(*)
      @rows ||= [{ closed:, received: }]
    end

    private

    def closed
      scope.of_type(closing_event_types).count
    end

    def received
      scope.of_type(opening_event_types).count
    end

    def scope
      @scope ||= Rails.configuration.event_store.read.between(time_period.range)
    end

    def closing_event_types
      ReceivedOnReports::Configuration::CLOSING_EVENTS
    end

    def opening_event_types
      ReceivedOnReports::Configuration::OPENING_EVENTS
    end

    class << self
      def for_time_period(time_period:)
        new(time_period:)
      end
    end
  end
end
