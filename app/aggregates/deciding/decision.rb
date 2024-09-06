module Deciding
  class Decision
    include AggregateRoot

    def initialize(decision_id)
      @decision_id = decision_id
    end

    attr_reader :application_id, :decision_id, :funding_decision, :comment, :state

    def create_draft(user_id:, application_id:)
      apply DraftCreated.new(
        data: { decision_id:, application_id:, user_id: }
      )
    end

    def set_interests_of_justice(user_id:, interests_of_justice:)
      apply InterestsOfJusticeSet.new(
        data: { decision_id:, application_id:, user_id:, interests_of_justice: }
      )
    end

    def set_funding_decision(user_id:, funding_decision:)
      apply FundingDecisionSet.new(
        data: { decision_id:, application_id:, user_id:, funding_decision: }
      )
    end

    def set_comment(user_id:, comment:)
      apply CommentSet.new(
        data: { decision_id:, application_id:, user_id:, comment: }
      )
    end

    on DraftCreated do |event|
      @application_id = event.data.fetch(:application_id)
      @state = Types::DecisionState[:draft]
    end

    on InterestsOfJusticeSet do |event|
      @interests_of_justice = event.data.fetch(:interests_of_justice)
    end

    on FundingDecisionSet do |event|
      @funding_decision = event.data.fetch(:funding_decision)
    end

    on CommentSet do |event|
      @comment = event.data.fetch(:comment)
    end

    def interests_of_justice
      return {} if @interests_of_justice.nil?

      Types::InterestsOfJusticeDecision[@interests_of_justice]
    end
  end
end
