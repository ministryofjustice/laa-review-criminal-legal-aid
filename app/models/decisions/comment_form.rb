module Decisions
  class CommentForm
    include DecisionFormPersistance

    attribute :comment, :string
    attribute :comment_required, :boolean

    validates :comment_required, inclusion: [true, false]
    validates :comment, presence: { if: :comment_required }

    class << self
      def build(decision)
        new(
          comment: decision.comment,
          comment_required: decision.comment.present? ? true : nil,
          application_id: decision.application_id,
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
