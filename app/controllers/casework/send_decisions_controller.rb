module Casework
  class SendDecisionsController < Casework::BaseController
    before_action :set_crime_application, :set_decisions, :set_form
    before_action :redirect_if_add_another, only: [:create]

    def new; end

    def create
      @form_object.send_to_provider!(permitted_params, current_user_id)
      set_flash :completed_with_decisions
      redirect_to assigned_applications_path
    rescue ActiveModel::ValidationError, Reviewing::IncompleteDecisions
      render :new
    end

    private

    def redirect_if_add_another
      return unless permitted_params[:next_step] == 'add_another'

      redirect_to crime_application_link_maat_id_path
    end

    def set_decisions
      @decisions = current_crime_application.draft_decisions

      require_decisions
    end

    def require_decisions
      return if @decisions.present?

      redirect_to crime_application_path(@crime_application)
    end

    def set_form
      @form_object = ::Decisions::SendToProviderForm.new(
        application_id: @crime_application.id
      )
    end

    def permitted_params
      ::Decisions::SendToProviderForm.permit_params(params)
    end
  end
end
