module Deciding
  class Decision
    include AggregateRoot

    def initialize(decision_id)
      @decision_id = decision_id
    end

    attr_reader :application_id, :decision_id, :funding_decision, :comment,
                :state, :reference, :maat_id, :checksum, :case_id

    # For decisions entered on CrimeReview by the caseworker
    def create_draft(user_id:, application_id:, reference:)
      apply DraftCreated.new(
        data: { decision_id:, application_id:, user_id:, reference: }
      )
    end

    # For decisions from MAAT
    def link_draft(application_id:, linked_decision:)
      apply DraftLinked.new(
        data: { decision_id:, application_id:, linked_decision: }
      )
    end

    def sync_with_maat(maat_decision:)
      apply SynchedWithMaat.build(self, maat_decision:)
    end

    def set_interests_of_justice(user_id:, interests_of_justice:)
      apply InterestsOfJusticeSet.build(self, user_id:, interests_of_justice:)
    end

    def set_funding_decision(user_id:, funding_decision:)
      apply FundingDecisionSet.build(self, user_id:, funding_decision:)
    end

    def set_comment(user_id:, comment:)
      apply CommentSet.build(self, user_id:, comment:)
    end

    on DraftLinked do |event|
      @application_id = event.data.fetch(:application_id)

      maat_decision = Maat::Decision.new(event.data.fetch(:linked_decision))
      set_attributes(maat_decision)

      @maat_id = maat_decision.maat_id
      @state = Types::DecisionState[:draft]
    end

    on SynchedWithMaat do |event|
      return if event.data[:maat_decision].blank?

      maat_decision = Maat::Decision.new(event.data.fetch(:maat_decision))
      set_attributes(maat_decision)
    end

    on DraftCreated do |event|
      @application_id = event.data.fetch(:application_id)
      @reference = event.data.fetch(:reference, nil)
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

    def set_attributes(decision)
      @reference = decision.reference
      @case_id = decision.case_id
      @interests_of_justice = decision.interests_of_justice
      @means = decision.means
      @funding_decision = decision.funding_decision
      @checksum = decision.checksum
    end

    def interests_of_justice
      return {} if @interests_of_justice.nil?

      Types::InterestsOfJusticeDecision[@interests_of_justice]
    end

    def means
      return {} if @means.nil?

      Types::MeansDecision[@means]
    end
  end
end
