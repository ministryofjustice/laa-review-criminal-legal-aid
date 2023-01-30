class GetNext
  def initialize
    filter = ApplicationSearchFilter.new(assigned_status: 'unassigned')
    pagination = Pagination.new(limit_value: 1)
    @search = ApplicationSearch.new(filter:, pagination:)
  end

  def call
    @search.results.first&.id
  end
end
