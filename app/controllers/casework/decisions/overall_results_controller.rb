module Casework
  module Decisions
    class OverallResultsController < Casework::BaseController
      include DecisionFormControllerActions

      private

      def form_class
        ::Decisions::OverallResultForm
      end

      def next_step
        edit_crime_application_decision_comment_path
      end
    end
  end
end
