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
    end

    attr_reader :id, :state, :return_reason, :reviewed_at, :reviewer_id, :submitted_at

    alias application_id id

    def receive_application(submitted_at:)
      raise AlreadyReceived if received?

      apply ApplicationReceived.new(
        data: { application_id:, submitted_at: }
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

    def complete(user_id:)
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
      @submitted_at = event.data[:submitted_at]
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
