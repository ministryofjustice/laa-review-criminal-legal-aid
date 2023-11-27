module Reporting
  class ReturnReasonsReportSorting < ApplicationStruct
    SORTABLE_COLUMNS = %w[
      applicant_name
      reviewed_at
      return_reason
      reference
      office_code
    ].freeze

    DEFAULT_SORT_BY = 'reviewed_at'.freeze
    DEFAULT_SORT_DIRECTION = Types::SortDirection['ascending']

    include SortableStruct
  end
end
