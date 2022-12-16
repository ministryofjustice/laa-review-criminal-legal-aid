RSpec.configure do |config|
  application_ids = %w[
    696dd4fd-b619-4637-ab42-a5f4565bcf4a
    1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc
  ]

  config.before do
    stub_request(:get, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v2/applications?status=submitted")
      .to_return(
        body: file_fixture('crime_apply_data/applications.json').read,
        status: 200
      )

    stub_request(:get, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v2/applications/123")
      .to_return(
        body: file_fixture('crime_apply_data/responses/404.json').read,
        status: 404
      )

    application_ids.each do |application_id|
      stub_request(
        :get,
        "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v2/applications/#{application_id}"
      ).to_return(
        body: file_fixture("crime_apply_data/applications/#{application_id}.json").read,
        status: 200
      )
    end
  end
end
