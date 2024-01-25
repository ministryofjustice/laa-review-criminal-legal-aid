RSpec.shared_context 'with resubmitted application' do
  let(:parent_id) { '47a93336-7da6-48ec-b139-808ddd555a41' }
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  before do
    travel_to(Time.zone.local(2023, 1, 1))

    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
    ).to_return(body: application_data.to_json, status: 200)

    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{parent_id}"
    ).to_return(body: LaaCrimeSchemas.fixture(1.0, name: 'application_returned'), status: 200)

    user = User.create(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: '976658f9-f3d5-49ec-b0a9-485ff8b308fa',
      email: 'Fred.Smitheg@justice.gov.uk'
    )

    Reviewing::ReceiveApplication.call(
      application_id: parent_id,
      parent_id: nil,
      work_stream: 'extradition',
      submitted_at: Time.zone.now.to_s,
      application_type: 'initial'
    )

    Assigning::AssignToUser.new(
      user_id: user.id,
      to_whom_id: user.id,
      assignment_id: parent_id
    ).call

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new) {
      instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
    }

    return_details = ReturnDetails.new(
      reason: 'evidence_issue',
      details: 'September bank statement required'
    )

    Reviewing::SendBack.new(
      user_id: user.id,
      application_id: parent_id,
      return_details: return_details.attributes
    ).call

    travel_to(Time.zone.local(2023, 1, 2))

    Reviewing::ReceiveApplication.call(
      application_id: application_id,
      parent_id: parent_id,
      work_stream: 'extradition',
      submitted_at: Time.zone.now.to_s,
      application_type: 'initial'
    )
  end
end
