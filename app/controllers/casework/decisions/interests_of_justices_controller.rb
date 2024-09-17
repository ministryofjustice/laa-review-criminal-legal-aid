module Casework
  module Decisions
    class InterestsOfJusticesController < Casework::BaseController
      include EditableDecision

      before_action :set_form

      private

      def form_class
        ::Decisions::InterestsOfJusticeForm
      end

      def permitted_params
        params[:decisions_interests_of_justice_form].permit(
          :result, :details, :assessed_by, :assessed_on
        )
      end

      def next_step
        edit_crime_application_decision_funding_decision_path
      end
    end
  end
end
