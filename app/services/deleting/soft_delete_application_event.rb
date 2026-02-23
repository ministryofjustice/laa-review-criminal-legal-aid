module Deleting
  # Service responsible for processing soft deletion events and publishing
  # Deleting domain events.
  #
  # Usage:
  #   Deleting::SoftDeleteApplicationEvent.call(id: message_id, data: message_data)
  #
  class SoftDeleteApplicationEvent
    attr_reader :message

    def self.call(id:, data:)
      new(id:, data:).call
    end

    def initialize(id:, data:)
      @message = SoftDeletionMessage.new(id:, data:)
    end

    def call
      event = Deleting::SoftDeleted.new(
        data: {
          reference: message.reference,
          soft_deleted_at: message.soft_deleted_at,
          reason: message.reason,
          deleted_by: message.deleted_by
        }
      )

      Rails.configuration.event_store.publish(event)
    end
  end
end
