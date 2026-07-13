class DataTableComponent < GovukComponent::TableComponent
  renders_one :sortable_head, ->(sorting:) { DataTable::HeadComponent.new(sorting:) }

  def initialize(classes: [])
    super(classes: classes, html_attributes: {})
  end

  def call
    tag.table(**html_attributes) { safe_join([caption, colgroups, head, sortable_head, bodies, foot]) }
  end

  private

  def caption
    tag.caption do
      tag.span(
        I18n.t('table_headings.sortable_caption'),
        class: 'govuk-visually-hidden'
      )
    end
  end
end
