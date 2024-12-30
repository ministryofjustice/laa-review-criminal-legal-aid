module Casework
  class MaatDecisionsController < Casework::BaseController
    include SetDecisionAndAuthorise

    before_action :set_decision, :require_maat_decision!, except: [:create, :new, :create_by_reference]

    def new
      @form_object = ::Decisions::MaatIdForm.new(application: @crime_application)
    end

    # Used to create a decision when a caseworker needs to link to a decision
    # not imported directly from CrimeApply (e.g., for split cases or when an
    # import failed due to a technical issue).
    def create
      @form_object = ::Decisions::MaatIdForm.new(application: @crime_application)
      @form_object.create_with_user!(permitted_params, current_user_id)

      set_flash(:maat_decision_linked, maat_id: @form_object.maat_id)

      redirect_to crime_application_decision_comment_path(decision_id: @form_object.maat_id)
    rescue ActiveModel::ValidationError, Maat::RecordNotFound, Deciding::Error, Reviewing::Error
      render :new
    end

    # Creates a draft decision using the current application's reference.
    # This is the preferred method for adding a MAAT decision, but cannot
    # be used if the caseworker manually added the application to MAAT.
    def create_by_reference
      maat_decision = Maat::CreateDraftDecisionFromReference.call(
        application: @crime_application, user_id: current_user_id
      )

      set_flash(:maat_decision_linked, maat_id: maat_decision.maat_id)

      redirect_to crime_application_decision_comment_path(
        crime_application_id: @crime_application.id,
        decision_id: maat_decision.decision_id
      )
    rescue Maat::RecordNotFound
      set_flash(:linked_maat_decision_not_found, success: false, reference: @crime_application.reference)

      redirect_to crime_application_link_maat_id_path(@crime_application)
    end

    def update
      sync_with_maat

      redirect_to crime_application_decision_comment_path(
        crime_application_id: @crime_application.id,
        decision_id: @decision.decision_id
      )
    end

    def destroy
      Deciding::Unlink.call(
        application_id: @crime_application.id,
        user_id: current_user_id,
        decision_id: @decision.decision_id
      )

      set_flash :decision_removed, success: true

      redirect_to crime_application_send_decisions_path
    end

    private

    def permitted_params
      ::Decisions::MaatIdForm.permit_params(params)
    end

    def sync_with_maat
      Maat::UpdateDraftDecision.call(
        application: @crime_application, maat_id: @decision.decision_id, user_id: current_user_id
      )

      set_flash(:updated_from_maat, maat_id: @decision.maat_id)
    rescue Deciding::MaatRecordNotChanged
      set_flash(:no_change_since_last_update, success: false, maat_id: @decision.maat_id)
    end

    def require_maat_decision!
      raise Deciding::DecisionNotFound unless @decision.maat_id == params[:id].to_i
    end
  end
end
