RSpec.shared_context 'with stubbed assignments and reviews', shared_context: :metadata do
  let(:david) do
    User.create!(
      auth_oid: '35d581ba-b1f5-4d96-8b1d-233bfe67dfe5',
      first_name: 'David',
      last_name: 'Brown',
      email: 'David.Browneg@justice.gov.uk'
    )
  end

  let(:john) do
    User.create!(
      auth_oid: '992c1667-745f-4eda-848b-eec7cd92d7fa',
      first_name: 'John',
      last_name: 'Deere',
      email: 'John.Deereeg@justice.gov.uk'
    )
  end

  let(:johns_applications) { [SecureRandom.uuid, SecureRandom.uuid] }
  let(:davids_applications) { [SecureRandom.uuid] }

  let(:current_assignment_ids) do
    [johns_applications.first, davids_applications.first]
  end

  let(:unassigned_application_ids) { [SecureRandom.uuid] }

  before do
    # rubocop:disable Rails/SkipsModelValidations
    CurrentAssignment.insert({ user_id: john.id, assignment_id: johns_applications.first })
    CurrentAssignment.insert({ user_id: david.id, assignment_id: davids_applications.first })

    Review.insert({ reviewer_id: john.id, application_id: johns_applications.last })

    # Add non reviewed applications
    unassigned_application_ids.each do |application_id|
      Review.insert({
                      application_id: application_id,
        submitted_at: Time.current,
        business_day: BusinessDay.new(day_zero: Time.current).date
                    })
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
