module Decisions
  class CommentForm
    include DecisionFormPersistance

    attribute :comment, :string
    attribute :comment_required, :boolean

    validates :comment_required, inclusion: [true, false]
    validates :comment, presence: { if: :comment_required }

    # Set comment to be empty if comment not required
    def attributes
      return super if comment_required

      super.merge(comment: '') unless comment_required
    end

    class << self
      def build(decision)
        new(
          comment: decision.comment,
          comment_required: decision.comment.present? ? true : nil,
          application_id: decision.application_id,
          reference: decision.reference,
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
