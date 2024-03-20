class ApplicationSearchSorting < ApplicationStruct
  SORTABLE_COLUMNS = %w[
    applicant_name
    application_type
    case_type
    reviewed_at
    submitted_at
    time_passed
  ].freeze

  DEFAULT_SORT_BY = 'submitted_at'.freeze
  DEFAULT_SORT_DIRECTION = Types::SortDirection['ascending'].freeze

  include SortableStruct
end
