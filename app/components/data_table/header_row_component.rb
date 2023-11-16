module DataTable
  class HeaderRowComponent < GovukComponent::Base
    renders_many :cells, lambda { |colname: nil, colspan: 1, scope: 'col', classes: [], numeric: false, text: nil|
      sorting = @sorting

      DataTable::HeaderCellComponent.new(
        sorting:, classes:, colname:, colspan:, scope:, numeric:, text:
      )
    }

    def initialize(sorting:, classes: [])
      @sorting = sorting
      super(classes: classes, html_attributes: {})
    end

    def call
      tag.tr(**html_attributes) { safe_join(cells) }
    end

    private

    def default_attributes
      { class: "#{brand}-table__row" }
    end
  end
end
