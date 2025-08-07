module Aws
  class MessageProcessor
    attr_reader :message

    def self.process!(message)
      new(message:).process!
    end

    def initialize(message:)
      @message = message
      @event = resolve_event
    end

    def process!
      Rails.logger.debug { "Processing '#{message.event_name}' event #{message.id}: #{message.data}" }
      @event.new(id: message.id, data: message.data).create!
    end

    private

    def resolve_event
      case message.event_name
      when 'apply.submission' then ReceiveApplicationEvent
      end
    end
  end
end
