class ApplicationSearch
  def initialize(filter:, sorting: Sorting.new)
    @filter = filter
    @sorting = sorting
  end

  def results
    @results ||= datastore_search_response.map do |result|
      ApplicationSearchResult.new result
    end
  end

  def total
    @total ||= datastore_search_response.pagination['total_count']
  end

  private

  include DatastoreApi::Traits::ApiRequest
  include DatastoreApi::Traits::PaginatedResponse

  def datastore_search_response
    @datastore_search_response ||= DatastoreApi::Requests::SearchApplications.new(
      **@filter.as_json
    ).call
    # @datastore_search_response ||= paginated_response(
    #   http_client.post('/searches', datastore_params)
    # )
  end

  # PENDING api client updated
  #
  # def datastore_params
  #   {
  #     search: @filter.as_json,
  #     pagination: {},
  #     sorting: @sorting.to_h
  #   }
  # end
end
