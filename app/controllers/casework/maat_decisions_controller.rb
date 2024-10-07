module Casework
  class MaatDecisionsController < Casework::BaseController
    # Used for managing linked decisions and manually linking a decision by MAAT ID.
    # See DefaultMaatDecisionsController
    include SetDecisionAndAuthorise

    before_action :set_decision, except: [:create, :new]
    before_action :set_maat_decision, except: [:create, :new]

    def new
      @form_object = ::Decisions::MaatIdForm.new(
        application_id: @crime_application.id
      )
    end

    def edit
      sync_with_maat

      redirect_to edit_crime_application_decision_comment_path(
        crime_application_id: @crime_application.id,
        decision_id: @decision.decision_id
      )
    end

    def update
      sync_with_maat

      redirect_to crime_application_path(@crime_application)
    end

    # Create by the current applications reference, which is the default
    # in most cases. See create #create_by_maat_id for other case.
    def create
      permitted_params = ::Decisions::MaatIdForm.permit_params(params)
    
      maat_id = permitted_params['maat_id']

      if maat_id.present?
        maat_decision = Maat::GetDecision.new.by_maat_id(maat_id)
      else
        maat_decision = Maat::GetDecision.new.by_usn(@crime_application.reference)
      end

      # raise if reference is set and does not match current application
      #
      if maat_decision.present?
        args = {
          application_id: @crime_application.id,
          user_id: current_user_id,
          decision_id: maat_decision.decision_id
        }

        ActiveRecord::Base.transaction do
          Reviewing::AddMaatDecision.call(**args)
          Deciding::CreateDraftFromMaat.call(**args, maat_decision:)
        end

        set_flash(:maat_decision_linked, maat_id: maat_decision.maat_id)

        redirect_to edit_crime_application_decision_comment_path(
          crime_application_id: @crime_application.id,
          decision_id: maat_decision.decision_id
        )
      else
        set_flash(:linked_maat_decision_not_found, success: false, reference: @crime_application.reference)

        redirect_to new_crime_application_maat_decision_path(@crime_application)
      end
    end

    # #create_by_maat_id is used when a caseworker needs to link to a decision
    # not imported directly from CrimeApply. (Such as split case or when importing
    # failed for a technical reason.)
    def create_by_maat_id
      maat_decision = Maat::GetDecision.new.by_maat_id(
        ::Decisions::MaatIdForm.permit_params(params)['maat_id']
      )

      if maat_decision.present?
        args = {
          application_id: @crime_application.id,
          user_id: current_user_id,
          decision_id: maat_decision.decision_id
        }

        ActiveRecord::Base.transaction do
          Reviewing::AddMaatDecision.call(**args)
          Deciding::CreateDraftFromMaat.call(**args, maat_decision:)
        end

        set_flash(:maat_decision_linked, maat_id: maat_decision.maat_id)

        redirect_to edit_crime_application_decision_comment_path(
          crime_application_id: @crime_application.id,
          decision_id: maat_decision.decision_id
        )
      else
        set_flash(:linked_maat_decision_not_found, success: false, reference: @crime_application.reference)

        redirect_to new_crime_application_maat_decision_path(@crime_application)
      end
    end


    private

    def sync_with_maat
      maat_decision = Maat::GetDecision.new.by_maat_id(
        @decision.maat_id
      )

      if maat_decision&.checksum != @decision.checksum
        Deciding::UpdateFromMaatDecision.call(
          user_id: current_user_id,
          decision_id: @decision.decision_id,
          maat_decision: maat_decision
        )

        set_flash(:updated_from_maat, maat_id: maat_decision.maat_id)
      else
        set_flash(:no_change_since_last_update, success: false, maat_id: maat_decision.maat_id)
      end
    end

    def set_maat_decision
      set_decision

      raise Deciding::DecisionNotFound unless @decision.maat_id.present?
    end
  end
end
