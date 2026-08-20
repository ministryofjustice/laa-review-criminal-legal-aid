module CaseworkerReports
  class WorkQueueProjection
    def initialize(stream_name:)
      @stream_name = stream_name
    end

    def dataset
      @dataset ||= begin
        event_store = Rails.application.config.event_store
        projection = build_projection
        projection.call(event_store.read.stream(@stream_name))
      end
    end

    private

    def build_projection # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      projection = RubyEventStore::Projection.init(Hash.new { |h, k| h[k] = {} })
      projection.on(Assigning::AssignedToUser) do |rows, event|
        user_id = event.data.fetch(:to_whom_id)
        review = Review.find_by(application_id: event.data.fetch(:assignment_id))
        count_event(rows: rows, counter: :assign, user_id: user_id, work_queue: review.work_stream,
                    is_pse: review.pse?)
        rows
      end
      projection.on(Assigning::ReassignedToUser) do |rows, event|
        user_id = event.data.fetch(:to_whom_id)
        review = Review.find_by(application_id: event.data.fetch(:assignment_id))
        count_event(rows: rows, counter: :reassign_to, user_id: user_id, work_queue: review.work_stream,
                    is_pse: review.pse?)

        user_id = event.data.fetch(:from_whom_id)
        count_event(rows: rows, counter: :reassign_from, user_id: user_id, work_queue: review.work_stream,
                    is_pse: review.pse?)
        rows
      end
      projection.on(Assigning::UnassignedFromUser) do |rows, event|
        user_id = event.data.fetch(:from_whom_id)
        review = Review.find_by(application_id: event.data.fetch(:assignment_id))
        count_event(rows: rows, counter: :unassign, user_id: user_id, work_queue: review.work_stream,
                    is_pse: review.pse?)
        rows
      end
      projection.on(Reviewing::SentBack) do |rows, event|
        user_id = event.data.fetch(:user_id)
        review = Review.find_by(application_id: event.data.fetch(:application_id))
        count_event(rows: rows, counter: :send_back, user_id: user_id, work_queue: review.work_stream,
                    is_pse: review.pse?)
        rows
      end
      projection.on(Reviewing::Completed) do |rows, event|
        user_id = event.data.fetch(:user_id)
        review = Review.find_by(application_id: event.data.fetch(:application_id))
        count_event(rows: rows, counter: :complete, user_id: user_id, work_queue: review.work_stream,
                    is_pse: review.pse?)
        rows
      end
      projection
    end

    def count_event(rows:, counter:, user_id:, work_queue:, is_pse:)
      rows[user_id][work_queue] ||= Row.new(user_id, work_queue)
      rows[user_id][work_queue].send(counter)
      return unless is_pse

      rows[user_id]['post_submission_evidence'] ||= Row.new(user_id, 'post_submission_evidence')
      rows[user_id]['post_submission_evidence'].send(counter)
    end
  end
end
