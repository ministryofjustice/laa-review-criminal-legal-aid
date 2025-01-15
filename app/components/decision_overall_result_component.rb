class DecisionOverallResultComponent < ViewComponent::Base
  with_collection_parameter :decision

  def initialize(decision:)
    @means_result = decision.means&.result
    @funding_decision = decision.funding_decision

    super
  end

  def call
    return if funding_decision.nil?

    govuk_tag(
      text: t(overall_result, scope: [:values, :decision_overall_result]),
      colour: colour
    )
  end

  private

  attr_reader :funding_decision, :means_result

  # TODO: move to the decision model if overall result decision confirmed
  # otherwise use the MAAT decision
  #
  def overall_result
    return 'granted_failed_means' if granted? && failed_means?
    return 'granted_with_contribution' if granted? && with_contribution?

    funding_decision
  end

  def granted?
    funding_decision == Types::FundingDecision['granted']
  end

  def failed_means?
    means_result == Types::TestResult['failed']
  end

  def with_contribution?
    means_result == Types::TestResult['passed_with_contribution']
  end

  def colour
    {
      Types::FundingDecision['granted'] => 'green',
      Types::FundingDecision['refused'] => 'red'
    }.fetch(funding_decision, nil)
  end
end
