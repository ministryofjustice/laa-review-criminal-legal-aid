class DecisionResultComponent < ViewComponent::Base
  def initialize(result: nil)
    @result = result

    super
  end

  def call
    return if result.nil?

    govuk_tag(
      text: t(result, scope: [:values, :decision_result]),
      colour: colour
    )
  end

  private

  attr_reader :result

  def colour
    case result
    when /fail/
      'red'
    else
      'green'
    end
  end
end