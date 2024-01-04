class ApplicationSearchSorting < ApplicationStruct
  SORTABLE_COLUMNS = %w[
    submitted_at
    time_passed
    reviewed_at
    applicant_name
    case_type
  ].freeze

  DEFAULT_SORT_BY = 'submitted_at'.freeze
  DEFAULT_SORT_DIRECTION = Types::SortDirection['ascending'].freeze

  include SortableStruct
end
