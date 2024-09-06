module Deciding
  class Decision
    include AggregateRoot

    def initialize(decision_id)
      @decision_id = decision_id
      @application_id = nil
      @case_id = nil
      @maat_id = nil
      @interests_of_justice = nil
      @means = nil
      @state = nil
    end

    attr_reader :interests_of_justice, :decision_id

    def create_draft(user_id:, application_id:)
      apply DraftCreated.new(
        data: { decision_id:, application_id:, user_id: }
      )
    end

    def set_interests_of_justice(user_id:, details:)
      # TODO: ignore if not changed
      apply InterestsOfJusticeSet.new(
        data: { user_id:, details: }
      )
    end

    on DraftCreated do |event|
      @interests_of_justice = event.data.fetch(:details)
      @application_id = event.data.fetch(:application_id)
      @state = Types::DecisionState[:draft]
    end

    on InterestsOfJusticeSet do |event|
      @interests_of_justice = event.data.fetch(:details)
    end

    def interests_of_justice
      return if @interests_of_justice.nil?

      Types::InterestsOfJusticeDecision[@interests_of_justice]
    end
  end
end
