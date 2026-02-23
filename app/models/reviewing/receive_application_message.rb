module Reviewing
  class ReceiveApplicationMessage
    attr_reader :id, :data

    alias causation_id id

    def initialize(id:, data:)
      @id = id
      @data = data
    end

    def application_id
      data['id']
    end

    def submitted_at
      data['submitted_at']
    end

    def application_type
      data['application_type']
    end

    def parent_id
      data.fetch('parent_id', application_id)
    end

    def work_stream
      data.fetch('work_stream')
    end

    def reference
      data.fetch('reference')
    end
  end
end
