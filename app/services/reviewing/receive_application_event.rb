module Reviewing
  # Service responsible for processing incoming application events and creating
  # Reviewing domain events.
  #
  # Usage:
  #   Reviewing::ReceiveApplicationEvent.call(id: message_id, data: message_data)
  #
  class ReceiveApplicationEvent
    attr_reader :message

    def self.call(id:, data:)
      new(id:, data:).call
    end

    def initialize(id:, data:)
      @message = ReceiveApplicationMessage.new(id:, data:)
    end

    def call # rubocop:disable Metrics/AbcSize
      Reviewing::ReceiveApplication.call(
        application_id: message.application_id,
        parent_id: message.parent_id,
        work_stream: message.work_stream,
        application_type: message.application_type,
        causation_id: message.causation_id,
        submitted_at: message.submitted_at,
        reference: message.reference
      )
    rescue Reviewing::AlreadyReceived
      Rails.logger.warn('Application already received')
    end
  end
end
