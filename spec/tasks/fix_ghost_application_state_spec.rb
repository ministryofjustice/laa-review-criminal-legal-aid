require 'rails_helper'
require 'rake'

RSpec.describe 'fix_ghost_application_state', type: :task do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:application_id) { SecureRandom.uuid }
  let(:reference) { 12_345_678 }
  let(:decision_id) { 9_874_622 }
  let(:submitted_at) { Time.current }
  let(:user) do
    User.create!(
      auth_oid: '35d581ba-b1f5-4d96-8b1d-233bfe67dfe5',
      first_name: 'User',
      last_name: 'A',
      email: 'User.A@justice.gov.uk'
    )
  end
  let(:crime_application) do
    CrimeApplication.new(
      reference: reference,
      id: application_id,
      parent_id: nil,
      application_type: 'initial',
      schema_version: 1.0,
      client_details: { applicant: {} },
      provider_details: { office_code: '' },
      created_at: Time.parse('2025-11-18 12:00:00 UTC').iso8601,
      submitted_at: Time.parse('2025-11-18 12:00:00 UTC').iso8601
    )
  end
  let(:event_store) { Rails.configuration.event_store }

  let(:return_request) do
    instance_double(
      DatastoreApi::Requests::UpdateApplication,
      call: JSON.parse(
        LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read
      )
    )
  end

  before do
    Rake::Task.define_task(:environment)
    Rake.application.rake_require 'tasks/ghost_applications'

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).with(
      {
        application_id: application_id,
        payload: true,
        member: :mark_as_ready
      }
    ).and_return(return_request)

    travel_to Time.zone.local(2025, 11, 18, 12)
    Reviewing::ReceiveApplication.call(
      application_id: application_id,
      reference: reference,
      submitted_at: submitted_at,
      work_stream: 'criminal_applications_team',
      application_type: 'initial'
    )
    Assigning::AssignToUser.call(
      assignment_id: application_id,
      user_id: user.id,
      to_whom_id: user.id,
      reference: reference
    )
    Reviewing::MarkAsReady.call(
      application_id: application_id,
      user_id: user.id
    )
    Deciding::CreateDraftFromMaat.call(
      decision_id: decision_id,
      maat_decision: Decisions::Draft.new(
        reference: reference,
        funding_decision: 'granted',
        decision_id: decision_id,
        maat_id: decision_id,
        application_id: application_id,
        assessment_rules: 'magistrates_court',
        overall_result: 'granted'
      ),
      user_id: user.id
    )
    Reviewing::AddDecision.call(
      application_id: application_id,
      user_id: user.id,
      decision_id: decision_id
    )
    Deciding::Link.call(
      application_id: application_id,
      decision_id: decision_id,
      application_type: 'initial',
      reference: reference,
      user_id: user.id
    )
    Deciding::SetComment.call(
      decision_id: decision_id,
      user_id: user.id,
      comment: 'comment'
    )

    travel_back
  end

  it 'reflects the incorrect state of the application' do # rubocop:disable RSpec/ExampleLength
    expect(Review.find_by(application_id:).attributes).to include(
      'state' => 'open',
      'reviewer_id' => nil,
      'submitted_at' => submitted_at,
      'reviewed_on' => nil,
      'application_type' => 'initial',
      'work_stream' => 'criminal_applications_team'
    )
    expect(CurrentAssignment.assigned_to_ids(user_id: user.id)).to eq([application_id])
  end

  it 'corrects the state of the application' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    Rake::Task['fix_ghost_application_state'].invoke(application_id, decision_id, user.id)

    expect(Review.find_by(application_id:).attributes).to include(
      'state' => 'completed',
      'reviewer_id' => user.id,
      'submitted_at' => submitted_at,
      'reviewed_on' => Time.new(2025, 11, 18).utc,
      'application_type' => 'initial',
      'work_stream' => 'criminal_applications_team'
    )
    expect(CurrentAssignment.assigned_to_ids(user_id: user.id)).to be_empty
    expect(event_store.read.stream("Deciding$#{decision_id}").last).to be_instance_of(Deciding::SentToProvider)
    expect(event_store.read.stream("Deciding$#{decision_id}").last.data).to include(
      application_id: application_id,
      decision_id: decision_id,
      user_id: user.id
    )
    expect(event_store.read.stream("Deciding$#{decision_id}").last.metadata.to_h).to include(
      timestamp: Time.parse('2025-11-18 14:38:16.738541 UTC'),
      valid_at: Time.parse('2025-11-18 14:38:16.738541 UTC')
    )
    expect(event_store.read.stream("Reviewing$#{application_id}").last).to be_instance_of(Reviewing::Completed)
    expect(event_store.read.stream("Reviewing$#{application_id}").last.data).to include(
      application_id: application_id,
      reference: reference,
      submitted_at: submitted_at,
      parent_id: nil,
      work_stream: 'criminal_applications_team',
      application_type: 'initial',
      user_id: user.id
    )
    expect(event_store.read.stream("Reviewing$#{application_id}").last.metadata.to_h).to include(
      timestamp: Time.parse('2025-11-18 14:38:16.75725 UTC'),
      valid_at: Time.parse('2025-11-18 14:38:16.75725 UTC')
    )
    expect(crime_application.history.items.first.attributes).to include(
      user_name: 'User A',
      event_type: 'Reviewing::Completed',
      timestamp: Time.parse('2025-11-18 14:38:16.75725 UTC')
    )
  end
end
