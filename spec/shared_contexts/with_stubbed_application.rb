RSpec.shared_context 'with stubbed application' do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:income_details) { {} }
  let(:outgoings_details) { {} }
  let(:capital_details) { {} }
  let(:means_details) { { income_details:, outgoings_details:, capital_details: } }
  let(:partner_included?) { false }

  let(:application_data) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
      'client_details' => { 'partner' => { 'is_included_in_means_assessment' => partner_included? } },
      'means_details' => means_details.deep_stringify_keys
    )
  end

  before do
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
    ).to_return(body: application_data.to_json, status: 200)
  end
end
