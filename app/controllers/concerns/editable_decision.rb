module EditableDecision 
  extend ActiveSupport::Concern

  included do
    before_action :set_crime_application
    before_action :set_decision
    before_action :confirm_assigned
    before_action :set_form
  end

  def edit; end

  def update
    @form_object.update_with_user!(
      permitted_params, current_user_id
    )

    redirect_to next_step
  rescue ActiveModel::ValidationError
    render :edit
  end

  private

  def set_decision
    decision = Deciding::LoadDecision.call(
      decision_id: params[:decision_id]
    )

    raise Deciding::DecisionNotFound unless decision.application_id == current_crime_application.id 

    @decision = decision
  end

  def set_form
    @form_object = form_class.build(@decision)
  end

  def confirm_assigned
    raise Deciding::DecisionNotFound unless @crime_application.reviewable_by?(current_user_id)
  end
end
