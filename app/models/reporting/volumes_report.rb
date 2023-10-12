module Reporting
  class VolumesReport
    # weekly intake processed, day for a week
    # monthly intake processed
    #
    #
    def initialize(day_zero: Time.current, interval: 'daily')
      @day_zero = day_zero.in_time_zone('London').to_date
      @interval = interval
    end

    def rows
      @rows ||= [
        {
          closed: closing_events.between(date_from...date_to).count,
          received: receiving_events.between(date_from...date_to).count
        }
      ]
    end

    private

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

    attr_reader :day_zero

    def closing_events
      closing_event_types = [Reviewing::SentBack, Reviewing::Completed]

      Rails.configuration.event_store.read.of_type(closing_event_types)
    end

    def receiving_events
      closing_event_types = [Reviewing::ApplicationReceived]

      Rails.configuration.event_store.read.of_type(closing_event_types).backward
    end

    class << self
      def for_temporal_period(date:, interval:)
        new(day_zero: date, interval: interval)
      end
    end
  end
end
