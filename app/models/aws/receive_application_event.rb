module Aws
  class ReceiveApplicationEvent
    attr_reader :id, :data

    alias causation_id id

    def initialize(id:, data:)
      @id = id
      @data = data
    end

    def create!
      Reviewing::ReceiveApplication.call(
        application_id:,
        parent_id:,
        work_stream:,
        application_type:,
        causation_id:,
        submitted_at:,
        reference:
      )
    rescue Reviewing::AlreadyReceived
      Rails.logger.warn('Application already received')
    end

    private

    def application_id
      data['id']
    end

    def submitted_at
      data['submitted_at'] || Time.zone.now
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
