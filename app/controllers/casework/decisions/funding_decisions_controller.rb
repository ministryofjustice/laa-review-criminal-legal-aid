module Casework
  module Decisions
    class FundingDecisionsController < Casework::BaseController
      include EditableDecision

      private

      def form_class
        ::Decisions::FundingDecisionForm
      end

      def permitted_params
        params[:decisions_funding_decision_form].permit(
          :result, :details
        )
      end

      def next_step
        crime_application_decisions_path
      end
    end
  end
end
