module DecisionFormControllerActions
  extend ActiveSupport::Concern

  included do
    include SetDecisionAndAuthorise

    before_action :set_form
  end

  def edit; end

  def update
    @form_object.update_with_user! permitted_params, current_user_id

    redirect_to next_step
  rescue ActiveModel::ValidationError
    render :edit
  end

  private

  def set_form
    @form_object = form_class.build(
      application: @crime_application, decision: @decision
    )
  end

  def permitted_params
    form_class.permit_params(params)
  end
end
