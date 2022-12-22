class ApplicationSearch
  def initialize(filter:)
    @filter = filter
  end

  def results
    @results ||= search.map do |result|
      ApplicationSearchResult.new result
    end
  end

  def total
    @total ||= search.pagination['total_count']
  end

  private

  def search
    @search ||= DatastoreApi::Requests::SearchApplications.new(
      **@filter.as_json
    ).call
  end
end
