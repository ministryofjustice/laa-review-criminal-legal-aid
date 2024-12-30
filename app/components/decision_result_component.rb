class DecisionResultComponent < ViewComponent::Base
  with_collection_parameter :result

  def initialize(result: nil)
    @result = result

    super
  end

  def call
    return if result.nil?

    govuk_tag(
      text: t(result, scope: [:values, :decision_overall_result]),
      colour: colour
    )
  end

  private

  attr_reader :result

  def colour
    {
      Types::FundingDecision['granted'] => 'green',
      Types::FundingDecision['refused'] => 'red'
    }.fetch(result, nil)
  end
end
