module Casework
  module Decisions
    class CommentsController < Casework::BaseController
      include DecisionFormControllerActions

      private

      def form_class
        ::Decisions::CommentForm
      end

      def next_step
        crime_application_decisions_path(@crime_application)
      end
    end
  end
end
