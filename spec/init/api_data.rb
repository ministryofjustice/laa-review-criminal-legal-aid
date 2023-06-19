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
    # All DatastoreApi search requests are stubbed to return empty result sets by default.
    # To return anything other than that include the shared_context "with stubbed search".
    #
    stub_request(:post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches")
      .to_return(
        body: { pagination: {}, records: [], sort: {} }.to_json,
        status: 201
      )

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
