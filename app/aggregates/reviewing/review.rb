module Reviewing
  class Review
    include AggregateRoot

    def initialize(id)
      @id = id
      @state = nil
      @return_reason = nil
    end

    attr_reader :id, :state, :return_reason

    alias application_id id

    def receive_application(application_id:)
      raise AlreadyReceived unless @state.nil?

      apply ApplicationReceived.new(
        data: { application_id: }
      )
    end

    def send_back(application_id:, user_id:, reason:)
      raise AlreadySentBack if @state.equal?(:sent_back)
      raise CannotSendBackWhenCompleted if @state.equal?(:completed)

      apply SentBack.new(
        data: { application_id:, user_id:, reason: }
      )
    end

    def complete(application_id:, user_id:)
      raise AlreadyCompleted if @state.equal?(:completed)
      raise CannotCompleteWhenSentBack if @state.equal?(:sent_back)

      apply Completed.new(
        data: { application_id:, user_id: }
      )
    end

    on ApplicationReceived do |_event|
      @state = :received
    end

    on SentBack do |event|
      @state = :sent_back
      @return_reason = event.data.fetch(:reason, nil)
    end

    on Completed do |_event|
      @assignee_id = nil
      @state = :completed
    end
  end
end
