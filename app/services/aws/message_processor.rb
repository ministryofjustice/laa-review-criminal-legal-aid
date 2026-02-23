module Aws
  class MessageProcessor
    attr_reader :message

    def self.process!(message)
      new(message:).process!
    end

    def initialize(message:)
      @message = message
    end

    def process! # rubocop:disable Metrics/AbcSize
      Rails.logger.debug { "Processing '#{message.event_name}' event #{message.id}: #{message.data}" }

      case message.event_name
      when 'apply.submission'
        Reviewing::ReceiveApplicationEvent.call(id: message.id, data: message.data)
      when 'Deleting::Archived'
        Deleting::ArchiveApplicationEvent.call(id: message.id, data: message.data)
      when 'Deleting::SoftDeleted'
        Deleting::SoftDeleteApplicationEvent.call(id: message.id, data: message.data)
      end
    end
  end
end
