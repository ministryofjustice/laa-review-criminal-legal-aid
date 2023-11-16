class GetNext
  def initialize
    filter = ApplicationSearchFilter.new(assigned_status: 'unassigned')
    pagination = Pagination.new(limit_value: 1)
    sorting = ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
    @search = ApplicationSearch.new(filter:, pagination:, sorting:)
  end

  def call
    @search.results.first&.id
  end
end
