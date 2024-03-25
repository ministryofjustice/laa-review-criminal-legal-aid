class CardComponent < ViewComponent::Base
  # Wraps the Govuk Summary Card component so that when used with
  # .with_collection the item number is added to the card title.

  with_collection_parameter :item

  attr_reader :item, :item_iteration

  def initialize(item:, title:, item_iteration: nil)
    @item = item
    @item_title = title
    @item_iteration = item_iteration

    super
  end

  def call
    govuk_summary_card(title:) { content }
  end

  def title
    safe_join([@item_title, count].compact, ' ')
  end

  private

  def count
    return unless item_iteration
    return unless item_iteration.size > 1

    item_iteration.index + 1
  end
end
