module Reviewing
  module Handlers
    class CompleteReview
      def call(event) # rubocop:disable Metrics/MethodLength
        application_id = event.data.fetch(:application_id, nil)
        return if application_id.blank?

        review = Reviewing::LoadReview.call(application_id:)

        decisions = review.draft_decisions.map do |draft|
          Decisions::Draft.build(draft).as_json
        end

        begin
          retries ||= 0

          DatastoreApi::Requests::UpdateApplication.new(
            application_id: application_id,
            payload: { decisions: },
            member: :complete
          ).call
        rescue DatastoreApi::Errors::ConflictError
          raise
        rescue DatastoreApi::Errors::ApiError => e
          Rails.error.report(e, handled: false, severity: :error)
          retry if (retries += 1) < 3
          raise
        end
      end
    end
  end
end
