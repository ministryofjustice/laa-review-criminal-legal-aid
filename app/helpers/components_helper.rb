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

  def decision_result(result)
    render DecisionResultComponent.new(result:)
  end

  def conflict_of_interest(codefendant)
    render ConflictOfInterestComponent.new(codefendant:)
  end

  def reviewing_actions(application)
    render ReviewActionComponent.with_collection(
      application.available_reviewer_actions, application:
    )
  end

  def reviewing_action(review_action, application)
    render ReviewActionComponent.new(review_action:, application:)
  end
end
