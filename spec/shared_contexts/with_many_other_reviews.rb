RSpec.shared_context 'with many other reviews', shared_context: :metadata do
  def insert_review_events(review_data = [])
    reviews = review_data.map do |review|
      { application_id: SecureRandom.uuid,
        business_day: review.fetch(:business_day, nil),
        reviewed_on: review.fetch(:reviewed_on, nil),
        work_stream: review.fetch(:work_stream, 'criminal_applications_team'),
        state: review.fetch(:state, 'open') }
    end
    Review.insert_all(reviews) # rubocop:disable Rails/SkipsModelValidations
  end
end
