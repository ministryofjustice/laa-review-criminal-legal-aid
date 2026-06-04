module DataTable
  class HeaderRowComponent < GovukComponent::Base
    renders_many :cells, lambda { |colname: nil, colspan: 1, scope: 'col', classes: [], numeric: false, text: nil|
      sorting = @sorting
      filter = @filter

      DataTable::HeaderCellComponent.new(
        sorting:, filter:, classes:, colname:, colspan:, scope:, numeric:, text:
      )
    }

    def initialize(sorting:, filter:, classes: [])
      @sorting = sorting
      @filter = filter
      super(classes: classes, html_attributes: {})
    end

    def call
      safe_join([
                  caption,
                  tag.tr(**html_attributes) { safe_join(cells) }
                ])
    end

    def caption
      tag.caption do
        tag.span(
          I18n.t('table_headings.sortable_caption'),
          class: 'govuk-visually-hidden'
        )
      end
    end

    private

    def default_attributes
      { class: "#{brand}-table__row" }
    end
  end
end
