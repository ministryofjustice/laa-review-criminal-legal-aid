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
  let(:davids_applications) { [SecureRandom.uuid, SecureRandom.uuid] }

  let(:current_assignment_ids) do
    [
      johns_applications.first, johns_applications.last,
      davids_applications.first, davids_applications.last,
    ]
  end

  before do
    allow(CurrentAssignment).to receive(:assigned_to_ids).with(user_id: john.id) {
      [johns_applications.first]
    }

    allow(CurrentAssignment).to receive(:assigned_to_ids).with(user_id: david.id) {
      [davids_applications.first]
    }

    allow(Review).to receive(:reviewed_by_ids).with(user_id: john.id) {
      [johns_applications.last]
    }

    allow(Review).to receive(:reviewed_by_ids).with(user_id: david.id) {
      [davids_applications.last]
    }

    allow(CurrentAssignment).to receive(:pluck).with(:assignment_id) {
      current_assignment_ids
    }
  end
end
