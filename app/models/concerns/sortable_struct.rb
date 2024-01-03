module SortableStruct
  extend ActiveSupport::Concern

  included do
    attribute? :sort_direction, Types::String.default(default_sort_direction).enum(*Types::SortDirection.values)
    attribute? :sort_by, Types::String.default(default_sort_by).enum(*sortable_columns)
  end

  class_methods do
    def sortable_columns
      self::SORTABLE_COLUMNS
    end

    def default_sort_by
      self::DEFAULT_SORT_BY
    end

    def default_sort_direction
      self::DEFAULT_SORT_DIRECTION
    end

    def new_or_default(params = nil)
      params ||= {
        sort_by: default_sort_by,
        sort_direction: default_sort_direction
      }
      new(**params)
    end
  end

  def reverse_direction
    return 'ascending' if sort_direction == 'descending'

    'descending'
  end
end
