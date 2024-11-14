module Decisions
  class CommentForm
    include DecisionFormPersistance

    attribute :comment, :string

    class << self
      def build(application:, decision:)
        new(
          comment: decision.comment,
          application: application,
          decision_id: decision.decision_id
        )
      end
    end

    private

    def command_class
      Deciding::SetComment
    end
  end
end
