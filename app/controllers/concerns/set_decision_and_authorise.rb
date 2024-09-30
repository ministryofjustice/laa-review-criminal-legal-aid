module SetDecisionAndAuthorise
  extend ActiveSupport::Concern

  included do
    before_action :confirm_feature_enabled
    before_action :set_crime_application
    before_action :set_decision
    before_action :confirm_assigned
  end

  private

  def set_decision
    decision = Deciding::LoadDecision.call(
      decision_id: params[:decision_id] || params[:id]
    )

    raise Deciding::DecisionNotFound unless decision.application_id == current_crime_application.id

    @decision = Decisions::Draft.build(decision)
  end

  def confirm_assigned
    raise Deciding::DecisionNotFound unless @crime_application.reviewable_by?(current_user_id)
  end

  def confirm_feature_enabled
    raise Deciding::DecisionNotFound unless FeatureFlags.adding_decisions.enabled?
  end
end
