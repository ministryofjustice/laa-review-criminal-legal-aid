class ConflictOfInterestComponent < ViewComponent::Base
  def initialize(codefendant:)
    @codefendant = codefendant

    super
  end

  def call
    return conflict_tag if answer == 'no'

    conflict_answer
  end

  private

  attr_reader :codefendant

  def conflict_answer
    tag.span(class: 'govuk-caption-m') { t(answer, scope: :values) }
  end

  def answer
    codefendant.conflict_of_interest
  end

  def conflict_tag
    govuk_tag(
      text: t(answer, scope: [:values, :conflict_of_interest_tag]),
      colour: 'red'
    )
  end
end
