class TableHeader < ApplicationStruct
  attribute :column_name, Types::String
  attribute :search, Types.Instance(ApplicationSearch)

  def name
    I18n.t(column_name, scope: 'table_headings')
  end

  def sortable?
    Types::SORTABLE_COLUMNS.include?(column_name)
  end

  #
  # Params required to sort by this column
  #
  def sorting_params
    sort_by = if column_name == 'time_passed'
                'submitted_at'
              else
                column_name
              end

    {
      sorting: {
        sort_by: sort_by,
        sort_direction: sorting.reverse_direction
      }
    }
  end

  delegate :sorting, to: :search

  #
  # returns 'ascending', 'descending' or 'none' depending on
  # the columns sort state if sortable.
  #
  def sort_state
    return nil unless sortable?

    column_name == sorting.sort_by ? sorting.sort_direction : 'none'
  end
end
