module Reviewing
  class Review
    include AggregateRoot

    def initialize(id)
      @id = id
      @decision_ids = []
    end

    attr_reader :id, :decision_ids, :state, :return_reason, :reviewed_at, :reviewer_id, :submitted_at, :superseded_by,
                :superseded_at, :parent_id, :work_stream, :application_type, :reference

    alias application_id id

    def receive_application(submitted_at:, application_type:, reference:, parent_id: nil, work_stream: nil)
      raise AlreadyReceived if received?

      apply ApplicationReceived.new(
        data: {
          application_id:, reference:, submitted_at:,
          parent_id:, work_stream:, application_type:
        }
      )
    end

    def send_back(user_id:, reason:)
      raise NotReceived unless received?
      raise AlreadySentBack if @state.equal?(:sent_back)
      raise CannotSendBackWhenCompleted if @state.equal?(:completed)

      apply SentBack.build(self, user_id:, reason:)
    end

    def supersede(superseded_at:, superseded_by:)
      apply Superseded.build(self, superseded_at:, superseded_by:)
    end

    def complete(user_id:)
      raise NotReceived unless received?
      raise AlreadyCompleted if @state.equal?(:completed)
      raise CannotCompleteWhenSentBack if @state.equal?(:sent_back)

      apply Completed.build(self, user_id:)
    end

    def mark_as_ready(user_id:)
      raise NotReceived unless received?
      raise AlreadyMarkedAsReady if @state.equal?(:marked_as_ready)
      raise CannotMarkAsReadyWhenSentBack if @state.equal?(:sent_back)
      raise CannotMarkAsReadyWhenCompleted if @state.equal?(:completed)

      apply MarkedAsReady.build(self, user_id:)
    end

    def add_decision(user_id:, decision_id:)
      apply DecisionAdded.build(self, user_id:, decision_id:)
    end

    on ApplicationReceived do |event|
      @state = Types::ReviewState[:open]
      @received_at = event.timestamp
      @submitted_at = event.data[:submitted_at]
      @parent_id = event.data[:parent_id]
      @application_type = event.data.fetch(:application_type, Types::ApplicationType['initial'])
      @work_stream = event.data.fetch(:work_stream, Types::WorkStreamType['criminal_applications_team'])
      @reference = event.data.fetch(:reference, nil)
    end

    on DecisionAdded do |event|
      @decision_ids << event.data.fetch(:decision_id)
    end

    on SentBack do |event|
      @state = Types::ReviewState[:sent_back]
      @return_reason = event.data.fetch(:reason, nil)
      @reviewer_id = event.data.fetch(:user_id)
      @reviewed_at = event.timestamp
    end

    on Superseded do |event|
      @superseded_at = event.data.fetch(:superseded_at)
      @superseded_by = event.data.fetch(:superseded_by)
    end

    on Completed do |event|
      @state = Types::ReviewState[:completed]
      @reviewer_id = event.data.fetch(:user_id)
      @reviewed_at = event.timestamp
    end

    on MarkedAsReady do |_event|
      @state = Types::ReviewState[:marked_as_ready]
    end

    def reviewed?
      !@reviewed_at.nil?
    end

    def received?
      !!state
    end

    def business_day
      BusinessDay.new(day_zero: @submitted_at) if @submitted_at.present?
    end

    def reviewed_on
      @reviewed_at.in_time_zone('London').to_date if @reviewed_at.present?
    end

    def available_reviewer_actions
      AvailableReviewerActions.for(self)
    end

    def available_funding_actions
      AvailableFundingActions.for(self)
    end
  end
end
