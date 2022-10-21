shared_context 'when applications exist' do
  before do
    stub_request(:get, "#{ENV.fetch('CRIME_APPLY_API_URL')}applications")
      .to_return(
        body: file_fixture('crime_apply_data/applications.json').read,
        status: 200
      )
  end
end

shared_context 'when a passported application exist' do
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:path) { "/applications/#{application_id}.json" }

  before do
    stub_request(:get, "#{ENV.fetch('CRIME_APPLY_API_URL')}applications/#{application_id}")
      .to_return(
        body: file_fixture("crime_apply_data/applications/#{application_id}.json").read,
        status: 200
      )
  end
end
