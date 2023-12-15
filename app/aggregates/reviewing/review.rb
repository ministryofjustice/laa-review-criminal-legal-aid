module Reviewing
  class Review
    include AggregateRoot

    def initialize(id)
      @id = id
      @state = nil
      @return_reason = nil
      @reviewer_id = nil
      @reviewed_at = nil
      @received_at = nil
      @submitted_at = nil
      @superseded_at = nil
      @superseded_by = nil
      @parent_id = nil
      @work_stream = nil
    end

    attr_reader :id, :state, :return_reason, :reviewed_at, :reviewer_id,
                :submitted_at, :superseded_by, :superseded_at, :parent_id,
                :work_stream

    alias application_id id

    def receive_application(submitted_at:, parent_id: nil, work_stream: nil)
      raise AlreadyReceived if received?

      apply ApplicationReceived.new(
        data: { application_id:, submitted_at:, parent_id:, work_stream: }
      )
    end

    def send_back(user_id:, reason:)
      raise NotReceived unless received?
      raise AlreadySentBack if @state.equal?(:sent_back)
      raise CannotSendBackWhenCompleted if @state.equal?(:completed)

      apply SentBack.new(
        data: { application_id:, user_id:, reason: }
      )
    end

    def supersede(superseded_at:, superseded_by:)
      apply Superseded.new(
        data: { application_id:, superseded_at:, superseded_by: }
      )
    end

    def complete(user_id:)
      raise NotReceived unless received?
      raise AlreadyCompleted if @state.equal?(:completed)
      raise CannotCompleteWhenSentBack if @state.equal?(:sent_back)

      apply Completed.new(
        data: { application_id:, user_id: }
      )
    end

    def mark_as_ready(user_id:)
      raise NotReceived unless received?
      raise AlreadyMarkedAsReady if @state.equal?(:marked_as_ready)
      raise CannotMarkAsReadyWhenSentBack if @state.equal?(:sent_back)
      raise CannotMarkAsReadyWhenCompleted if @state.equal?(:completed)

      apply MarkedAsReady.new(
        data: { application_id:, user_id: }
      )
    end

    on ApplicationReceived do |event|
      @state = :open
      @received_at = event.timestamp
      @submitted_at = event.data[:submitted_at]
      @parent_id = event.data[:parent_id]
      @work_stream = event.data.fetch(:work_stream, Types::WorkStreamType['criminal_applications_team'])
    end

    on SentBack do |event|
      @state = :sent_back
      @return_reason = event.data.fetch(:reason, nil)
      @reviewer_id = event.data.fetch(:user_id)
      @reviewed_at = event.timestamp
    end

    on Superseded do |event|
      @superseded_at = event.data.fetch(:superseded_at)
      @superseded_by = event.data.fetch(:superseded_by)
    end

    on Completed do |event|
      @state = :completed
      @reviewer_id = event.data.fetch(:user_id)
      @reviewed_at = event.timestamp
    end

    on MarkedAsReady do |_event|
      @state = :marked_as_ready
    end

    def reviewed?
      !@reviewed_at.nil?
    end

    def received?
      !!state
    end

    def business_day
      return nil unless @submitted_at

      BusinessDay.new(day_zero: @submitted_at)
    end

    def reviewed_on
      return nil unless @reviewed_at

      @reviewed_at.in_time_zone('London').to_date
    end
  end
end
