module ReceivedOnReports
  class Handler
    def call(event)
      application_id = event.data.fetch(:application_id)
      Rails.logger.debug application_id
      return unless application_id

      @review = Reviewing::LoadReview.call(application_id:)

      process_event!
    end

    # :nocov:
    def process_event!
      raise 'Implement in sub class.'
    end
    # :nocov:

    delegate :business_day, to: :@review
  end
end
