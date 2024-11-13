module Casework
  class LinkDecisionsController < Casework::BaseController
    include SetDecisionAndAuthorise

    before_action :set_decision, :require_maat_decision!, except: [:create, :new, :create_by_reference]

    def new
      maat_decision
    end

    def create
      maat_decision = Maat::CreateDefaultDraftDecision.call(
        application: @crime_application, user_id: current_user_id
      )

      set_flash(:maat_decision_linked, maat_id: maat_decision.maat_id)

      redirect_to edit_crime_application_decision_comment_path(
        crime_application_id: @crime_application.id,
        decision_id: maat_decision.decision_id
      )
    rescue Maat::RecordNotFound
      set_flash(:linked_maat_decision_not_found, success: false, reference: @crime_application.reference)

      redirect_to crime_application_link_maat_id_path(@crime_application)
    end

    private

    def application
      @crime_application
    end

    def reference
      return application.reference unless application.cifc?

      application.pre_cifc_usn if application.usn_selected?
    end

    def maat_id
      return unless application.cifc?

      application.pre_cifc_maat_id
    end

    def maat_decision
      @maat_decision ||= if reference.present?
                           Maat::GetDecision.new.by_usn!(reference)
                         else
                           Maat::GetDecision.new.by_maat_id!(maat_id)
                         end
    end
  end
end
