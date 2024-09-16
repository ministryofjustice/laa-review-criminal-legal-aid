class FundingDecisionComponent < ViewComponent::Base
  # Wraps the Govuk Summary Card component so that when used with
  # .with_collection the item number is added to the card title.

  def initialize(decision:, decision_iteration:)
    @item = item
    @item_title = title
    @item_iteration = item_iteration

    super
  end

  def call
    app_card_list
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
