RSpec.shared_context 'with resubmitted application' do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:parent_id) { '47a93336-7da6-48ec-b139-808ddd555a41' }
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:application_reference) { 123 }
  let(:parent_submitted_at) { '2022-09-27T15:10:00.000Z' }
  let(:child_submitted_at) { '2023-01-02T12:00:00.000Z' }

  let(:application_data) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
      'reference' => application_reference,
      'submitted_at' => child_submitted_at
    )
  end
  let(:parent_data) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read).deep_merge(
      'reference' => application_reference,
      'submitted_at' => parent_submitted_at
    )
  end

  before do
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
    ).to_return(body: application_data.to_json, status: 200)

    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{parent_id}"
    ).to_return(body: parent_data.to_json, status: 200)

    user = User.create(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: SecureRandom.uuid,
      email: 'Fred.Smitheg@justice.gov.uk'
    )

    # Parent application submitted on Sep 27, 2022
    travel_to(Time.zone.parse(parent_submitted_at))

    Reviewing::ReceiveApplication.call(
      application_id: parent_id,
      parent_id: nil,
      work_stream: 'extradition',
      submitted_at: parent_submitted_at,
      reference: application_reference,
      application_type: Types::ApplicationType['initial']
    )

    # Parent application assigned on Jan 1, 2023 12:00pm
    travel_to(Time.zone.local(2023, 1, 1, 12, 0, 0))

    Assigning::AssignToUser.new(
      user_id: user.id,
      to_whom_id: user.id,
      assignment_id: parent_id,
      reference: application_reference
    ).call

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new) {
      instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
    }

    return_details = ReturnDetails.new(
      reason: 'evidence_issue',
      details: 'September bank statement required'
    )

    # Parent application sent back on Jan 1, 2023 12:00pm
    Reviewing::SendBack.new(
      user_id: user.id,
      application_id: parent_id,
      return_details: return_details.attributes
    ).call

    # Child application (resubmission) received on Jan 2, 2023 12:00pm
    travel_to(Time.zone.parse(child_submitted_at))

    Reviewing::ReceiveApplication.call(
      application_id: application_id,
      parent_id: parent_id,
      work_stream: 'extradition',
      submitted_at: child_submitted_at,
      reference: application_reference,
      application_type: Types::ApplicationType['initial']
    )
  end
end
