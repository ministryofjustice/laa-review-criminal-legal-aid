module Casework
  class DecisionsController < Casework::BaseController
    include SetDecisionAndAuthorise

    before_action :set_decision, except: [:create]

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
