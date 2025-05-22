module CaseworkerReports
  class EventDataset
    def initialize(stream_name:)
      @stream_name = stream_name
    end

    attr_reader :stream_name

    def basic_projection
      @basic_projection ||= BasicProjection.new(stream_name:).dataset
    end

    def work_queue_projection
      @work_queue_projection ||= WorkQueueProjection.new(stream_name:).dataset
    end
  end
end
