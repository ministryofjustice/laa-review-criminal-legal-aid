module CaseworkerReports
  class UnassignedFromSelfProjection
    def initialize(stream_name:)
      @stream_name = stream_name
    end

    def dataset
      @dataset ||= load_from_events
    end

    private

    def load_from_events
      events = Rails.application.config.event_store
                    .read
                    .stream(@stream_name)
                    .of_type(Assigning::UnassignedFromUser)
                    .to_a

      events.each_with_object({}) do |event, rows|
        user_id = event.data.fetch(:from_whom_id)
        rows[user_id] ||= { user_id: user_id, assignment_ids: [] }
        rows[user_id][:assignment_ids] << event.data[:assignment_id]
      end
    end
  end
end
