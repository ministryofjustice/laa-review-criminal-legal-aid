module Reporting
  require 'csv'
  class VolumesByOfficeReport
    CSV_LIMIT = 5_000
    include Downloadable

    attr_reader :time_period, :sorting

    def initialize(time_period:)
      @time_period = time_period
    end

    def csv(*)
      CSV.generate do |csv|
        csv << %w[office_code submissions]

        dataset.each do |office_code, volume|
          csv << [office_code, volume]
        end
      end
    end

    def total_count
      dataset.size
    end

    private

    include DatastoreApi::Traits::ApiRequest

    def dataset
      return @dataset if @dataset.present?

      period = time_period.starts_on.strftime(Reporting::MonthlyReport::PARAM_FORMAT)
      @dataset = http_client.get("/reporting/volumes_by_office/monthly/#{period}").fetch('data')
    end

    class << self
      def for_time_period(time_period:, **_options)
        new(time_period:)
      end
    end
  end
end
