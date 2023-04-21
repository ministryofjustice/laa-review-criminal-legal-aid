class ApplicationSearch
  def initialize(filter:, pagination:, sorting: Sorting.new)
    @pagination = pagination
    @filter = filter
    @sorting = sorting
  end

  def results
    @results ||= datastore_search_response.map do |result|
      application = ApplicationSearchResult.new(result)

      # Receive the application if it has not yet been received.
      #
      # In production, Review is notified of new applications via SNS,
      # and, as such, the application should be received by this point.
      #
      # receive_if_required! is user here to:
      # 1. support other environments that do not have SNS set up,
      # 2. act as a failsafe should an application be returned by
      # the datastore before its SNS event message has been processed.

      application.receive_if_required!
    end
  end

  def total
    @total ||= pagination.total_count
  end

  def pagination
    Pagination.new(datastore_search_response.pagination)
  end

  attr_reader :sorting, :filter

  private

  include DatastoreApi::Traits::ApiRequest
  include DatastoreApi::Traits::PaginatedResponse

  def datastore_search_response
    @datastore_search_response ||= paginated_response(datastore_response)
  end

  def datastore_params
    {
      search: @filter.datastore_params,
      pagination: @pagination.datastore_params,
      sorting: @sorting.to_h
    }
  end

  def datastore_response
    http_client.post('/searches', datastore_params)
  rescue DatastoreApi::Errors::BadRequest
    { records: [], pagination: {} }
  end
end
