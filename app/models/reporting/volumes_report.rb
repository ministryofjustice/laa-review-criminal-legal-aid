module Reporting
  class VolumesReport
    def initialize(day_zero: Time.current, interval: 'daily')
      @day_zero = day_zero.in_time_zone('London').to_date
      @interval = interval
    end

    # Currently only CAT3 applications are processed on Review.
    def rows(*)
      @rows ||= [{ closed:, received: }]
    end

    private

    attr_reader :day_zero

    def closed
      scope.of_type(closing_event_types).count
    end

    def received
      scope.of_type(opening_event_types).count
    end

    def scope
      @scope ||= Rails.configuration.event_store.read.between(date_from...date_to)
    end

    def date_from
      case Types::TemporalInterval[@interval]
      when 'weekly'
        day_zero.beginning_of_week
      when 'daily'
        day_zero.beginning_of_day
      when 'monthly'
        day_zero.beginning_of_month
      end
    end

    def date_to
      case Types::TemporalInterval[@interval]
      when 'weekly'
        day_zero.end_of_week
      when 'daily'
        day_zero.end_of_day
      when 'monthly'
        day_zero.end_of_month
      end
    end

    def closing_event_types
      ReceivedOnReports::Configuration::CLOSING_EVENTS
    end

    def opening_event_types
      ReceivedOnReports::Configuration::OPENING_EVENTS
    end

    class << self
      def for_temporal_period(date:, interval:)
        new(day_zero: date, interval: interval)
      end
    end
  end
end
