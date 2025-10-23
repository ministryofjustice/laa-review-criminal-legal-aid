module Reporting
  class TimePeriod
    attr_reader :interval

    def initialize(interval:, date: Time.current)
      @date = date.in_time_zone('London').to_date
      @interval = Types::TemporalInterval[interval]
    end

    # The date of an interval need not be the same for it to be considered
    # equivalent to another. Only the range and the interval string.
    def ==(other)
      interval == other.interval && range == other.range
    end

    def range
      starts_on..ends_on
    end

    def starts_on
      case interval
      when 'weekly'
        date.beginning_of_week
      when 'daily'
        date
      when 'monthly'
        date.beginning_of_month
      end
    end

    def ends_on
      case interval
      when 'weekly'
        date.end_of_week
      when 'daily'
        date
      when 'monthly'
        date.end_of_month
      end
    end

    def ends_before
      ends_on + 1
    end

    def next
      self.class.new(interval: interval, date: next_date)
    end

    def previous
      self.class.new(interval: interval, date: previous_date)
    end

    private

    def previous_date
      case interval
      when 'weekly'
        date - 7
      when 'daily'
        date - 1
      when 'monthly'
        date << 1
      end
    end

    def next_date
      case interval
      when 'weekly'
        date + 7
      when 'daily'
        date + 1
      when 'monthly'
        date >> 1
      end
    end

    attr_reader :date
  end
end
