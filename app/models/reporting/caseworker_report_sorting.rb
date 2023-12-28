module Reporting
  class CaseworkerReportSorting < ApplicationStruct
    SORTABLE_COLUMNS = %w[
      user_name
      total_assigned_to_user
      total_unassigned_from_user
      total_closed_by_user
      percentage_unassigned_from_user
      percentage_closed_by_user
      percentage_closed_sent_back
    ].freeze

    DEFAULT_SORT_BY = 'user_name'.freeze
    DEFAULT_SORT_DIRECTION = Types::SortDirection['ascending'].freeze

    include SortableStruct
  end
end
