module Casework
  class DecisionsController < Casework::BaseController
    include SetDecisionAndAuthorise

    before_action :set_decision, except: [:create, :index, :add_another]
    
    def index
      @decisions = current_crime_application.draft_decisions
      @form_object = ::Decisions::AddAnotherForm.new
    end

    def add_another
      permitted_params = params[:decisions_add_another_form].
        permit(:add_another_decision)

      @form_object = ::Decisions::AddAnotherForm.new(permitted_params)

      if @form_object.valid?
        if @form_object.add_another_decision
          redirect_to new_crime_application_maat_decision_path(@crime_application)
        else
          redirect_to crime_application_path(@crime_application)
        end
      else
        @decisions = current_crime_application.draft_decisions
        render :index
      end
    end

    def create
      decision_id = SecureRandom.uuid

      args = {
        application_id: @crime_application.id,
        user_id: current_user_id,
        decision_id: decision_id,
        reference: @crime_application.reference
      }

      ActiveRecord::Base.transaction do
        Reviewing::AddDecision.call(**args)
        Deciding::CreateDraft.call(**args)
      end

      redirect_to edit_crime_application_decision_interests_of_justice_path(**args)
    end

    private

    def permitted_params
      form_class.permit_params(params)
    end
  end
end
