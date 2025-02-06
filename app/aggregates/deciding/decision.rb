module Deciding
  class Decision # rubocop:disable Metrics/ClassLength
    include AggregateRoot

    def initialize(decision_id)
      @decision_id = decision_id
    end

    attr_reader :application_id, :decision_id, :funding_decision, :comment,
                :state, :reference, :maat_id, :checksum, :case_id, :means, :interests_of_justice,
                :assessment_rules

    # When decision is drafted on Review by the caseworker (e.g. Non-means tested)
    def create_draft(application_id:, user_id:, reference:)
      raise AlreadyCreated unless @state.nil?

      apply DraftCreated.new(
        data: { decision_id:, application_id:, user_id:, reference: }
      )
    end

    # When the decision is created from a MAAT record
    def create_draft_from_maat(application_id:, maat_decision:, user_id:, application_type:)
      raise AlreadyCreated unless @state.nil?

      maat_decision = maat_decision.to_h
      apply DraftCreatedFromMaat.new(
        data: { decision_id:, application_id:, maat_decision:, user_id:, application_type: }
      )
    end

    # Can only be linked if the decision is not linked
    def link(application_id:, user_id:)
      raise AlreadyLinked if @application_id.present?

      apply Linked.build(self, user_id:, application_id:)
    end

    # A CIFC application can only be linked when the decision is in a sent state.
    def link_to_cifc(application_id:, user_id:)
      raise AlreadyLinked unless @state == :sent_to_provider

      apply LinkedToCifc.build(self, user_id:, application_id:)
    end

    def sync_with_maat(maat_decision:, user_id:)
      apply SynchedWithMaat.build(self, maat_decision: maat_decision.to_h, user_id: user_id)
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

    def unlink(user_id:, application_id:)
      raise NotLinked unless @application_id == application_id
      raise NotDraft unless @state == :draft

      apply Unlinked.build(self, user_id:)
    end

    def send_to_provider(user_id:, application_id:)
      raise NotLinked unless @application_id == application_id
      raise IncompleteDecision unless complete?

      apply SentToProvider.build(self, user_id:)
    end

    # When decision is drafted on Review by the caseworker (e.g. Non-means tested)
    on DraftCreated do |event|
      @application_id = event.data.fetch(:application_id)
      @reference = event.data.fetch(:reference, nil)
      @assessment_rules = Types::AssessmentRules['non_means']
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

    on Unlinked do |_event|
      @application_id = nil
      @reference = nil
      @comment = nil
    end

    on Linked do |event|
      @application_id = event.data.fetch(:application_id)
      @reference = event.data.fetch(:reference, nil)
    end

    # Original reference is retained when linking to CIFC
    on LinkedToCifc do |event|
      @application_id = event.data.fetch(:application_id)
    end

    on SentToProvider do |_event|
      @state = Types::DecisionState[:sent_to_provider]
    end

    def update_from_maat(maat_attributes)
      decision = Decisions::Draft.new(maat_attributes.except(:overall_result))

      @case_id = decision.case_id
      @checksum = decision.checksum
      @assessment_rules = decision.assessment_rules
      @funding_decision = decision.funding_decision
      @interests_of_justice = decision.interests_of_justice
      @maat_id = decision.maat_id
      @means = decision.means
      @reference = decision.reference
    end

    def overall_result
      return unless funding_decision

      OverallResultCalculator.new(self).calculate
    end

    def complete?
      @funding_decision.present?
    end
  end
end
