module Reporting
  class UnassignedFromSelfReportSorting < ApplicationStruct
    SORTABLE_COLUMNS = %w[
      applicant_name
      application_type
      submitted_at
      case_type
      reviewed_at
    ].freeze

    DEFAULT_SORT_BY = 'submitted_at'.freeze
    DEFAULT_SORT_DIRECTION = Types::SortDirection['ascending'].freeze

    include SortableStruct
  end
end
