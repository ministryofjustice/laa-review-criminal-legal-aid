module Deleting
  class SoftDeletionMessage
    attr_reader :id, :data

    alias causation_id id

    def initialize(id:, data:)
      @id = id
      @data = data
    end

    def reference
      data.fetch('reference')
    end

    def soft_deleted_at
      data.fetch('soft_deleted_at')
    end

    def reason
      data.fetch('reason')
    end

    def deleted_by
      data.fetch('deleted_by')
    end
  end
end
