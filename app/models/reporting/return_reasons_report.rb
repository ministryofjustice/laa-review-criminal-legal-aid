module Reporting
  require 'csv'

  class ReturnReasonsReport
    CSV_LIMIT = 1_000

    include Downloadable

    attr_reader :time_period, :sorting

    def initialize(time_period:, sorting:, page:)
      @time_period = time_period
      @sorting = ReturnReasonsReportSorting.new_or_default(sorting)
      @page = page
    end

    def rows
      dataset.map do |row|
        ReturnReasonsReportRow.new(row)
      end
    end

    def total_count
      @total_count ||= pagination.total_count
    end

    def pagination
      Pagination.new(dataset.pagination) if @dataset
    end

    private

    def filter
      ApplicationSearchFilter.new(
        application_status: 'sent_back',
        reviewed_before: time_period.ends_before,
        reviewed_after: time_period.starts_on
      )
    end

    def dataset
      return @dataset if @dataset

      datastore_params = {
        search: filter.datastore_params,
        pagination: Pagination.new(current_page: @page).datastore_params,
        sorting: sorting.to_h
      }

      @dataset = paginated_response(http_client.post('/searches', datastore_params))
    end

    include DatastoreApi::Traits::ApiRequest
    include DatastoreApi::Traits::PaginatedResponse

    class << self
      def for_time_period(time_period:, sorting:, page:)
        new(time_period:, sorting:, page:)
      end
    end
  end
end
