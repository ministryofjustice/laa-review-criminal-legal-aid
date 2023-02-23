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
    end

    attr_reader :id, :state, :return_reason, :reviewed_at, :reviewer_id

    alias application_id id

    def receive_application(application_id:, correlation_id: nil)
      raise AlreadyReceived if received?

      causation_id = correlation_id

      apply ApplicationReceived.new(
        metadata: { correlation_id:, causation_id: },
        data: { application_id: }
      )
    end

    def send_back(application_id:, user_id:, reason:)
      raise NotReceived unless received?
      raise AlreadySentBack if @state.equal?(:sent_back)
      raise CannotSendBackWhenCompleted if @state.equal?(:completed)

      apply SentBack.new(
        data: { application_id:, user_id:, reason: }
      )
    end

    def complete(application_id:, user_id:)
      raise NotReceived unless received?
      raise AlreadyCompleted if @state.equal?(:completed)
      raise CannotCompleteWhenSentBack if @state.equal?(:sent_back)

      apply Completed.new(
        data: { application_id:, user_id: }
      )
    end

    on ApplicationReceived do |event|
      @state = :open
      @received_at = event.timestamp
    end

    on SentBack do |event|
      @state = :sent_back
      @return_reason = event.data.fetch(:reason, nil)
      @reviewer_id = event.data.fetch(:user_id)
      @reviewed_at = event.timestamp
    end

    on Completed do |event|
      @state = :completed
      @reviewer_id = event.data.fetch(:user_id)
      @reviewed_at = event.timestamp
    end

    def reviewed?
      !@reviewed_at.nil?
    end

    def received?
      state != nil
    end
  end
end
