class Sorting < ApplicationStruct
  attribute? :sort_direction, Types::String.default('descending').enum('descending', 'ascending')
  attribute? :sort_by,
             Types::String.default('submitted_at').enum('submitted_at', 'reviewed_at', 'reference', 'applicant_name')

  def reverse_direction
    return 'ascending' if sort_direction == 'descending'

    'descending'
  end

  def aria_sort(column_name)
    column_name == sort_by ? sort_direction : 'none'
  end
end
