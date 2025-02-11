RSpec.configure do |config|
  config.before do
    #
    # Stub for valid returned application for Kit Pound, fixture provided by the LaaCrimeSchemas Gem
    #
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a"
    ).to_return(body: LaaCrimeSchemas.fixture(1.0).read, status: 200)

    #
    # Stub for valid application for Kit Pound, fixture provided by the LaaCrimeSchemas Gem
    #
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/47a93336-7da6-48ac-b139-808ddd555a41"
    ).to_return(body: LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read, status: 200)

    #
    # For sending back the returned fixture application
    #
    stub_request(
      :put,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/47a93336-7da6-48ac-b139-808ddd555a41/return"
    ).to_return(body: LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read, status: 200)

    #
    # For resubmission testing
    #
    resubmission_data = JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
      'id' => '012a553f-e9b7-4e9a-a265-67682b572fd0',
      'parent_id' => 'ff32c3e6-a88e-4d3d-a595-5a11b0aea9ef',
      'client_details' => { 'applicant' => { 'first_name' => 'Jessica', 'last_name' => 'Rhode' } }
    )

    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/012a553f-e9b7-4e9a-a265-67682b572fd0"
    ).to_return(body: resubmission_data.to_json, status: 200)

    original_submission_data = JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
      'id' => 'ff32c3e6-a88e-4d3d-a595-5a11b0aea9ef',
      'parent_id' => nil,
      'client_details' => { 'applicant' => { 'first_name' => 'Jessica', 'last_name' => 'Rhode' } }
    )

    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/ff32c3e6-a88e-4d3d-a595-5a11b0aea9ef"
    ).to_return(body: original_submission_data.to_json, status: 200)

    #
    # For an application not found on the datastore
    #
    stub_request(:get, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/123")
      .to_return(
        body: file_fixture('crime_apply_data/responses/404.json').read,
        status: 404
      )
  end
end
