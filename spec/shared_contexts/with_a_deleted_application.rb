RSpec.shared_context 'with a deleted application' do
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:application_data) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'anonymised_application').read)
        .merge('soft_deleted_at' => 1.week.ago)
  end

  before do
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
    ).to_return(body: application_data.to_json, status: 200)
  end
end
