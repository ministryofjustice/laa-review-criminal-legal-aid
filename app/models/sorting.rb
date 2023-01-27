class Sorting < ApplicationStruct
  attribute? :sort_direction, Types::SortDirection

  attribute? :sort_by, Types::SortBy

  def reverse_direction
    return 'ascending' if sort_direction == 'descending'

    'descending'
  end

  def column_sort_state(column_name)
    column_name == sort_by ? sort_direction : 'none'
  end
end
