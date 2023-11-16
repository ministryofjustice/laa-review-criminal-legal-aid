module DataTable
  class HeadComponent < GovukComponent::Base
    renders_many :rows, lambda { |classes: []|
      DataTable::HeaderRowComponent.new(sorting: @sorting, classes: classes)
    }

    def initialize(sorting:, classes: [])
      @sorting = sorting

      super(classes: classes, html_attributes: {})
    end

    def call
      tag.thead(**html_attributes) { safe_join(rows) }
    end

    private

    def default_attributes
      { class: "#{brand}-table__head" }
    end
  end
end
