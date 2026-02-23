module Deleting
  # Service responsible for processing archived application events and publishing
  # Deleting domain events.
  #
  # Usage:
  #   Deleting::ArchiveApplicationEvent.call(id: message_id, data: message_data)
  #
  class ArchiveApplicationEvent
    attr_reader :message

    def self.call(id:, data:)
      new(id:, data:).call
    end

    def initialize(id:, data:)
      @message = ArchivedMessage.new(id:, data:)
    end

    def call
      event = Deleting::Archived.new(
        data: {
          application_id: message.application_id,
          application_type: message.application_type,
          reference: message.reference,
          archived_at: message.archived_at
        }
      )

      Rails.configuration.event_store.publish(event)
    end
  end
end
