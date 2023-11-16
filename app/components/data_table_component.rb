class DataTableComponent < GovukComponent::TableComponent
  renders_one :sortable_head, ->(sorting:) { DataTable::HeadComponent.new(sorting:) }

  def initialize(classes: [])
    super(classes: classes, html_attributes: {})
  end

  def call
    tag.table(**html_attributes) { safe_join([caption, colgroups, head, sortable_head, bodies, foot]) }
  end
end
