class Sorting < ApplicationStruct
  attribute? :sort_direction, Types::SortDirection

  def reverse_direction
    return 'ascending' if sort_direction == 'descending'

    'descending'
  end
end
