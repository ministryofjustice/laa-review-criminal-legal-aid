module Reporting
  class UnassignedFromSelfReport
    def initialize(dataset:, user_id: nil)
      @dataset = dataset
      @user_id = user_id
    end

    def rows
      if @user_id
        dataset.fetch(@user_id, { assignment_ids: [] })[:assignment_ids]
      else
        dataset.values
      end
    end

    class << self
      def for_time_period(time_period:, user_id: nil, **)
        stream_name = CaseworkerReports.stream_name(
          date: time_period.starts_on,
          interval: time_period.interval
        )

        dataset = CaseworkerReports::UnassignedFromSelfProjection.new(stream_name:).dataset
        new(dataset:, user_id:)
      end
    end

    private

    attr_reader :dataset
  end
end
