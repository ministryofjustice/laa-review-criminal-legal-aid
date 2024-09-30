module Deciding
  class Decision
    include AggregateRoot

    def initialize(decision_id)
      @decision_id = decision_id
    end

    attr_reader :application_id, :decision_id, :funding_decision, :comment,
                :state, :reference, :maat_id, :checksum, :case_id, :means,
                :interests_of_justice

    # When decision is drafted on Review by the caseworker (e.g. Non-means tested)
    def create_draft(user_id:, application_id:, reference:)
      raise AlreadyCreated unless @state.nil?

      apply DraftCreated.new(
        data: { decision_id:, application_id:, user_id:, reference: }
      )
    end

    # When the decision is created from a MAAT record
    def create_draft_from_maat(application_id:, maat_decision:, user_id:)
      maat_decision = maat_decision.to_h
      raise AlreadyCreated unless @state.nil?

      apply DraftCreatedFromMaat.new(
        data: { decision_id:, application_id:, maat_decision:, user_id: }
      )
    end

    def sync_with_maat(maat_decision:, user_id:)
      raise MaatRecordNotChanged unless maat_decision&.checksum != checksum

      apply SynchedWithMaat.build(self, maat_decision:, user_id:)
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

    # When decision is drafted on Review by the caseworker (e.g. Non-means tested)
    on DraftCreated do |event|
      @application_id = event.data.fetch(:application_id)
      @reference = event.data.fetch(:reference, nil)
      @state = Types::DecisionState[:draft]
    end

    # When the decision is created from a MAAT record
    on DraftCreatedFromMaat do |event|
      @application_id = event.data.fetch(:application_id)

      update_from_maat(event.data.fetch(:maat_decision))

      @state = Types::DecisionState[:draft]
    end

    on SynchedWithMaat do |event|
      return if event.data[:maat_decision].blank?

      update_from_maat(event.data.fetch(:maat_decision))
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

    def update_from_maat(maat_attributes)
      decision = Maat::Decision.new(maat_attributes)

      @maat_id = decision.maat_id
      @reference = decision.reference
      @case_id = decision.case_id
      @interests_of_justice = decision.interests_of_justice
      @means = decision.means
      @funding_decision = decision.funding_decision
      @checksum = decision.checksum
    end

    def complete?
      @funding_decision.present?
    end

    def attributes
      {
        interests_of_justice:,
        funding_decision:,
        comment:
      }
    end
  end
end
