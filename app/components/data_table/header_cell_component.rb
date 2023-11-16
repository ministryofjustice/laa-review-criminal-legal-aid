module DataTable
  class HeaderCellComponent < GovukComponent::Base
    def initialize(colname:, scope:, colspan:, sorting:, numeric:, text:, classes: []) # rubocop:disable Metrics/ParameterLists
      @colname = colname
      @text = text
      @colspan = colspan
      @numeric = numeric
      @scope = scope
      @sorting = sorting

      super(classes: classes, html_attributes: {})
    end

    attr_reader :sorting, :colname, :colspan, :scope, :numeric, :text

    def call
      tag.th(**html_attributes) do
        if sortable?
          button_to(name, nil, params: sorting_params, method: :get)
        else
          name
        end
      end
    end

    private

    def default_classes
      class_names(
        "#{brand}-table__header",
        "#{brand}-table__header--numeric" => numeric
      )
    end

    def default_attributes
      {
        class: default_classes,
        id: colname,
        colspan: colspan,
        scope: scope,
        aria: { sort: sort_state }
      }
    end

    def name
      text || sanitize(I18n.t(colname, scope: 'table_headings'))
    end

    def sortable?
      sorting.class::SORTABLE_COLUMNS.include?(colname.to_s)
    end

    def sorting_params
      {
        sorting: {
          sort_by: colname,
          sort_direction: sorting.reverse_direction
        }
      }
    end

    #
    # returns 'ascending', 'descending' or 'none' depending on
    # the columns sort state if sortable.
    #
    def sort_state
      return nil unless sortable?

      colname.to_s == sorting.sort_by ? sorting.sort_direction : 'none'
    end
  end
end
