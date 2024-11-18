module Casework
  module Decisions
    class InterestsOfJusticesController < Casework::BaseController
      include DecisionFormControllerActions

      private

      def form_class
        ::Decisions::InterestsOfJusticeForm
      end

      def next_step
        crime_application_decision_overall_result_path
      end
    end
  end
end
