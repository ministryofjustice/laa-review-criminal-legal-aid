shared_context 'when applications exist' do
  before do
    stub_request(:get, "#{ENV.fetch('CRIME_APPLY_API_URL')}applications")
      .to_return(
        body: file_fixture('crime_apply_data/applications.json').read,
        status: 200
      )
  end
end
