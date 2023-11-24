module Reporting
  class ReturnReasonsReport
    attr_reader :time_period

    def initialize(time_period:)
      @time_period = time_period
    end

    def rows(sorting:)
      dataset(sorting:).map do |row|
        ReturnReasonsReportRow.new(row)
      end
    end

    private

    def pagination
      Pagination.new(limit_value: 100)
    end

    def filter
      ApplicationSearchFilter.new(
        application_status: 'sent_back',
        reviewed_before: time_period.ends_before,
        reviewed_after: time_period.starts_on
      )
    end

    def dataset(sorting:)
      datastore_params = {
        search: filter.datastore_params,
        pagination: pagination.datastore_params,
        sorting: sorting.to_h
      }

      paginated_response(http_client.post('/searches', datastore_params))
    end

    include DatastoreApi::Traits::ApiRequest
    include DatastoreApi::Traits::PaginatedResponse

    class << self
      def for_time_period(time_period:)
        new(time_period:)
      end
    end
  end
end
