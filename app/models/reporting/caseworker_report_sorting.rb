module Reporting
  class CaseworkerReportSorting < Sorting
    SORTABLE_COLUMNS = %w[
      user_name
      total_assigned_to_user
      total_unassigned_from_user
      total_closed_by_user
      percentage_unassigned_from_user
      percentage_closed_by_user
    ].freeze

    DEFAULT_SORT_BY = 'user_name'.freeze

    attribute :sort_direction, Types::SortDirection
    attribute :sort_by, Types::String.default(DEFAULT_SORT_BY).enum(*SORTABLE_COLUMNS)

    class << self
      def default
        new(sort_by: DEFAULT_SORT_BY)
      end
    end
  end
end
