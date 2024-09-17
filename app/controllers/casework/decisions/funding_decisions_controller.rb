module Casework
  module Decisions
    # rename overall result?
    class FundingDecisionsController < Casework::BaseController
      include EditableDecision

      before_action :set_form

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
