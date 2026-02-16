module Aws
  class ArchivedEvent
    attr_reader :id, :data

    alias causation_id id

    def initialize(id:, data:)
      @id = id
      @data = data
    end

    def create!
      event = Deleting::Archived.new(
        data: { application_id:, application_type:, reference:, archived_at: }
      )

      Rails.configuration.event_store.publish(event)
    end

    private

    def application_id
      data['id']
    end

    def application_type
      data['application_type']
    end

    def reference
      data.fetch('reference')
    end

    def archived_at
      data.fetch('archived_at')
    end
  end
end
