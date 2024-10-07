module Casework
  class DecisionsController < Casework::BaseController
    include SetDecisionAndAuthorise

    before_action :set_decision, except: [:create]

    def create_linked_maat_decision
      # redirect to crime app show if already linked
      maat_decision = Maat::GetDecision.new.by_usn(reference)

      ActiveRecord::Base.transaction do
        Deciding::CreateMaatDraft.call(application_id:, maat_decision:, decision_id:)
        Reviewing::AddMaatDecision.call(application_id:, decision_id:, maat_id:)
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
  end
end
