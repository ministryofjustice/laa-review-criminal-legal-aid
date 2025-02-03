class DecisionOverallResultComponent < ViewComponent::Base
  include AppTextHelper

  with_collection_parameter :decision

  def initialize(decision:)
    @decision = decision

    super
  end

  def call
    return if overall_result.nil?

    govuk_tag(text: value_text(overall_result, scope: :decision_overall_result), colour: colour)
  end

  private

  attr_reader :decision

  delegate :overall_result, :funding_decision, to: :decision

  def colour
    {
      Types::FundingDecision['granted'] => 'green',
      Types::FundingDecision['refused'] => 'red'
    }.fetch(funding_decision, nil)
  end
end
