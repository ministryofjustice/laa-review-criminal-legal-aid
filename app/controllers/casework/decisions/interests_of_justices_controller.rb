module Casework
  module Decisions
    class InterestsOfJusticesController < Casework::BaseController
      before_action :set_crime_application

      def edit
        agg = Deciding::LoadDecision.call(
          decision_id: params[:decision_id]
        )

        @interests_of_justice = ::Decisions::InterestsOfJustice.new(agg.interests_of_justice)
      end

      def update
        @interests_of_justice = ::Decisions::InterestsOfJustice.new(
          interests_of_justice_params
        )

        @interests_of_justice.validate!

        Deciding::SetInterestsOfJustice.new(
          decision_id: params[:decision_id],
          user_id: current_user_id,
          details: @interests_of_justice.attributes.deep_symbolize_keys
        ).call

        redirect_to crime_application_decision_path(
          crime_application_id: params[:crime_application_id], id:
          params[:decision_id]
        )
      rescue ActiveModel::ValidationError
        render :edit
      end

      private

      def draft_decision
        @crime_application.decision
      end

      def interests_of_justice_params
        params[:decisions_interests_of_justice].permit(
          :result, :reason, :assessed_by, :assessed_on
        )
      end

      def set_means_decision; end
    end
  end
end
