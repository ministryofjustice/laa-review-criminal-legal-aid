RSpec.shared_context 'with a completed application' do
  before do
    stub_request(
      :put,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}/complete"
    ).to_return(body: LaaCrimeSchemas.fixture(1.0).read, status: 200)

    user = User.create(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: '976658f9-f3d5-49ec-b0a9-485ff8b308fa',
      email: 'Fred.Smitheg@justice.gov.uk'
    )

    Assigning::AssignToUser.new(
      user_id: user.id,
      to_whom_id: user.id,
      assignment_id: crime_application_id,
      reference: 120_398_120
    ).call

    Reviewing::Complete.new(
      user_id: user.id,
      application_id: crime_application_id
    ).call
  end
end
