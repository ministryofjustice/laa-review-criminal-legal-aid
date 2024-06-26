module ComponentsHelper
  def app_card_list(items:, item_name:, &block)
    render CardComponent.with_collection(items, title: item_name), &block
  end

  def offence_class(offence)
    render OffenceClassComponent.new(offence:)
  end

  def offence_dates(offence)
    render OffenceDatesComponent.new(offence:)
  end

  def conflict_of_interest(codefendant)
    render ConflictOfInterestComponent.new(codefendant:)
  end
end
