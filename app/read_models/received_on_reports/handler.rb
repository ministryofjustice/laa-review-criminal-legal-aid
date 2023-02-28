module ReceivedOnReports
  class Handler
    def call(event)
      application_id = event.data.fetch(:application_id, nil)
      return unless application_id

      @review = Reviewing::LoadReview.call(application_id:)

      store_event!
    end

    # :nocov:
    def store_event!
      raise 'Implement in sub class.'
    end
    # :nocov:

    private

    def business_day
      @business_day = BusinessDay.new(day_zero: @review.submitted_at).date
    end
  end
end
