module Deciding
  class Decision
    include AggregateRoot

    def initialize(decision_id)
      @decision_id = decision_id
      @interests_of_justice = nil
    end

    attr_accessor :application_id, :decision_id, :result, :details, :state

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

    def set_funding_decision(user_id:, result:, details:)
      apply FundingDecisionSet.new(
        data: { decision_id:, application_id:, user_id:, result:, details: }
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
      @result = event.data.fetch(:result)
      @details = event.data.fetch(:details)
    end

    def interests_of_justice
      return if @interests_of_justice.nil?

      Types::InterestsOfJusticeDecision[@interests_of_justice]
    end

    def to_param
      decision_id
    end
  end
end
