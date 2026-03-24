module CaseworkerReports
  class WorkQueueProjection
    def initialize(stream_name:)
      @scope = RailsEventStore::Projection.from_stream(stream_name)
    end

    def dataset # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @dataset ||=
        @scope.init(-> { Hash.new { |hash, key| hash[key] = {} } })
              .when(
                Assigning::AssignedToUser,
                lambda { |rows, event|
                  user_id = event.data.fetch(:to_whom_id)
                  review = Review.find_by(application_id: event.data.fetch(:assignment_id))
                  count_event(rows: rows, counter: :assign, user_id: user_id, work_queue: review.work_stream,
                              is_pse: review.pse?)
                }
              )
              .when(
                Assigning::ReassignedToUser,
                lambda { |rows, event|
                  user_id = event.data.fetch(:to_whom_id)
                  review = Review.find_by(application_id: event.data.fetch(:assignment_id))
                  count_event(rows: rows, counter: :reassign_to, user_id: user_id, work_queue: review.work_stream,
                              is_pse: review.pse?)

                  user_id = event.data.fetch(:from_whom_id)
                  count_event(rows: rows, counter: :reassign_from, user_id: user_id, work_queue: review.work_stream,
                              is_pse: review.pse?)
                }
              )
              .when(
                Assigning::UnassignedFromUser,
                lambda { |rows, event|
                  user_id = event.data.fetch(:from_whom_id)
                  review = Review.find_by(application_id: event.data.fetch(:assignment_id))
                  count_event(rows: rows, counter: :unassign, user_id: user_id, work_queue: review.work_stream,
                              is_pse: review.pse?)
                }
              )
              .when(
                Reviewing::SentBack,
                lambda { |rows, event|
                  user_id = event.data.fetch(:user_id)
                  review = Review.find_by(application_id: event.data.fetch(:application_id))
                  count_event(rows: rows, counter: :send_back, user_id: user_id, work_queue: review.work_stream,
                              is_pse: review.pse?)
                }
              )
              .when(
                Reviewing::Completed,
                lambda { |rows, event|
                  user_id = event.data.fetch(:user_id)
                  review = Review.find_by(application_id: event.data.fetch(:application_id))
                  count_event(rows: rows, counter: :complete, user_id: user_id, work_queue: review.work_stream,
                              is_pse: review.pse?)
                }
              )
              .run(Rails.application.config.event_store)
    end

    private

    def count_event(rows:, counter:, user_id:, work_queue:, is_pse:)
      rows[user_id][work_queue] ||= Row.new(user_id, work_queue)
      rows[user_id][work_queue].send(counter)
      return unless is_pse

      rows[user_id]['post_submission_evidence'] ||= Row.new(user_id, 'post_submission_evidence')
      rows[user_id]['post_submission_evidence'].send(counter)
    end
  end
end
