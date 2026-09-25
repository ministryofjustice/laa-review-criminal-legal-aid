module Reporting
  class SlipstreamAuditReportSorting < ApplicationStruct
    SORTABLE_COLUMNS = %w[
      office_code
      application_type
      status
      submitted_at
      sampled_at
      ioj_outcome
    ].freeze

    DEFAULT_SORT_BY = 'submitted_at'.freeze
    DEFAULT_SORT_DIRECTION = Types::SortDirection['ascending'].freeze

    include SortableStruct
  end
end
