class GetNext
  def initialize(work_streams)
    filter = ApplicationSearchFilter.new(assigned_status: 'unassigned', work_stream: work_streams)
    pagination = Pagination.new(limit_value: 1)
    @search = ApplicationSearch.new(filter:, pagination:)
  end

  def call
    @search.results.first&.id
  end

  def self.call(work_streams:)
    work_streams = [] if work_streams.nil? # or blank?

    new(work_streams).call
  end
end
