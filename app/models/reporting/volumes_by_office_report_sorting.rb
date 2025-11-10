module Reporting
  class VolumesByOfficeReportSorting < ApplicationStruct
    SORTABLE_COLUMNS = %w[
      office_code
    ].freeze

    DEFAULT_SORT_BY = 'office_code'.freeze
    DEFAULT_SORT_DIRECTION = Types::SortDirection['ascending'].freeze

    include SortableStruct
  end
end
