class GetNext
  def initialize(work_streams:, application_types:)
    @application_types = application_types
    filter = ApplicationSearchFilter.new(assigned_status: 'unassigned', application_status: 'open',
                                         work_stream: work_streams, application_type: application_types)
    pagination = Pagination.new(limit_value: 1)
    sorting = ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
    @search = ApplicationSearch.new(filter:, pagination:, sorting:)
  end

  def call
    return nil if @application_types.empty?

    @search.results.first&.id
  end

  def self.call(work_streams:, application_types:)
    work_streams ||= []
    application_types ||= []

    new(work_streams:, application_types:).call
  end
end
