module Casework
  module Decisions
    class InterestsOfJusticesController < Casework::BaseController
      include EditableDecision

      private

      def form_class
        ::Decisions::InterestsOfJusticeForm
      end

      def next_step
        edit_crime_application_decision_funding_decision_path
      end

      def permitted_params
        params[:decisions_interests_of_justice_form].permit(
          :result, :details, :assessed_by, :assessed_on
        )
      end
    end
  end
end
