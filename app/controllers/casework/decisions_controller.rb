module Casework
  class DecisionsController < Casework::BaseController
    before_action :set_crime_application
    before_action :set_decision, only: [:show]

    def index
      @decisions = current_crime_application.review.decision_ids.map do |decision_id|
        agg = Deciding::LoadDecision.call(
          application_id: params[:crime_application_id],
          decision_id:
        )
      end
    end

    def show
    end

    def edit
      redirect_to edit_crime_application_decision_interests_of_justice_path(
        crime_application_id: params[:crime_application_id], decision_id:
        params[:id]
      )
    end

    def create
      decision_id = SecureRandom.uuid

      ActiveRecord::Base.transaction do
        Reviewing::AddDecision.new(
          application_id: params[:crime_application_id],
          user_id: current_user_id,
          decision_id: decision_id
        ).call

        Deciding::CreateDraft.new(
          application_id: params[:crime_application_id],
          user_id: current_user_id,
          decision_id: decision_id
        ).call
      end

      # Should we change path to be case 1, case 2 etc
      redirect_to edit_crime_application_decision_interests_of_justice_path(
        crime_application_id: params[:crime_application_id], decision_id: decision_id
      )
    end

    # TODO: scope decision by application
  end
end
