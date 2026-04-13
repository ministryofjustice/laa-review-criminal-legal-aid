module Deleting
  class ArchivedMessage
    attr_reader :id, :data

    alias causation_id id

    def initialize(id:, data:)
      @id = id
      @data = data
    end

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
