module Casework
  class DecisionsController < Casework::BaseController
    include EditableDecision

    before_action :set_decision, except: [:index, :create]

    def index
      @decisions = current_crime_application.review.decision_ids.map do |decision_id|
        Deciding::LoadDecision.call(
          application_id: params[:crime_application_id],
          decision_id: decision_id
        )
      end
    end

    def edit
      redirect_to edit_crime_application_decision_interests_of_justice_path(
        crime_application_id: params[:crime_application_id], decision_id:
        params[:id]
      )
    end

    def confirm_destroy; end

    def create
      decision_id = SecureRandom.uuid

      args = {
        application_id: @crime_application.id,
        user_id: current_user_id,
        decision_id: decision_id
      }

      ActiveRecord::Base.transaction do
        Reviewing::AddDecision.call(**args)
        Deciding::CreateDraft.call(**args)
      end

      redirect_to edit_crime_application_decision_interests_of_justice_path(
        crime_application_id: params[:crime_application_id], decision_id: decision_id
      )
    end

    def destroy
      args = {
        application_id: @crime_application.id,
        user_id: current_user_id,
        decision_id: @decision.decision_id
      }

      ActiveRecord::Base.transaction do
        Reviewing::RemoveDecision.new(**args).call
      end

      redirect_to action: :index
    end
  end
end
