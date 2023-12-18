module ReceivedOnReports
  class Row
    def initialize(work_stream:)
      @work_stream = work_stream
      @total_received = 0
      @closed_on_observed_business_day = 0
      @closed_before_observed_business_day = 0
    end

    attr_reader :total_received, :closed_on_observed_business_day

    def total_open
      total_received - total_closed
    end

    def total_closed
      @closed_on_observed_business_day + @closed_before_observed_business_day
    end

    def receive
      @total_received += 1
    end

    def close_on_observed_business_day
      @closed_on_observed_business_day += 1
    end

    def close_before_observed_business_day
      @closed_before_observed_business_day += 1
    end
  end
end
