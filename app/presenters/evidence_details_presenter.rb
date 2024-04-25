class EvidenceDetailsPresenter < BasePresenter
  def initialize(evidence_details)
    super(
      @evidence_details = evidence_details
    )
  end

  # NOTE: If the data structure has prompts generated but the predicate result was false then
  # the prompts are ignored
  def rules_for(group:, persona:)
    @evidence_details.evidence_prompts.select do |rule|
      (rule.group == group.to_s) && rule.run.respond_to?(persona) && rule.run.send(persona).result
    end
  end

  def show?
    @evidence_details.evidence_prompts.any? do |rule|
      rule.run.client.result || rule.run.partner.result || rule.run.other.result
    end
  end
end
