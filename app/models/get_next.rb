class GetNext
  def initialize(work_streams:)
    filter = ApplicationSearchFilter.new(assigned_status: 'unassigned', work_stream: work_streams)
    pagination = Pagination.new(limit_value: 1)
    sorting = ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
    @search = ApplicationSearch.new(filter:, pagination:, sorting:)
  end

  def call
    @search.results.first&.id
  end

  def self.call(work_streams:)
    work_streams = [] if work_streams.nil?

    new(work_streams:).call
  end
end
