class ApplicationSearchSorting < Sorting
  SORTABLE_COLUMNS = %w[
    submitted_at
    time_passed
    reviewed_at
    applicant_name
  ].freeze

  attribute? :sort_by, Types::String.enum(*SORTABLE_COLUMNS)
end
