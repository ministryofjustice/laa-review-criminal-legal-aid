module Reporting
  class BusinessDayAgeRangeRow
    def initialize(age_range_in_business_days:, observed_at:)
      @age_range_in_business_days = age_range_in_business_days
      @observed_at = observed_at.in_time_zone('London')
      @day_zero = observed_at.to_date
    end

    # Business days since application were received header column for table.
    # With current defaults, returns an array of header cells with contents:
    #
    # 0 days
    # 1 day
    # 2 days
    # Between 3 and 9 days
    def label
      if first == last
        I18n.t('values.days_passed', count: first)
      else
        I18n.t('values.days_passed_range', first:, last:)
      end
    end

    def total_received
      dataset.fetch(:total_received)
    end

    def total_open
      total_received - dataset.fetch(:total_closed)
    end

    private

    delegate :first, :last, to: :age_range_in_business_days

    attr_reader :day_zero, :observed_at, :age_range_in_business_days

    def dataset
      @dataset ||= sum_dataset_from_projections
    end

    def sum_dataset_from_projections
      projections.each_with_object({ total_received: 0, total_closed: 0 }) do |projection, total|
        total[:total_received] += projection.dataset[:total_received]
        total[:total_closed] += projection.dataset[:total_closed]
      end
    end

    def projections
      @projections ||= [*age_range_in_business_days].map do |age_in_business_days|
        business_day = BusinessDay.new(age_in_business_days:, day_zero:).date
        ReceivedOnReports::Projection.for_date(business_day, observed_at:)
      end
    end
  end
end
