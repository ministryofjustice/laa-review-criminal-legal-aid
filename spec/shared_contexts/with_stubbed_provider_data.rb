RSpec.shared_context 'with stubbed provider data' do
  let(:provider_office_details) do
    ProviderDataApi::OfficeDetails.new(
      'office' => {
        'addressLine1' => '102 Petty France',
        'addressLine2' => nil,
        'addressLine3' => nil,
        'addressLine4' => nil,
        'city' => 'London',
        'county' => nil,
        'postCode' => 'SW1H 9AJ'
      },
      'firm' => { 'firmName' => 'Test Firm' }
    )
  end

  before do
    allow(ProviderDataApi::GetOfficeDetails).to receive(:call).and_return(provider_office_details)
  end
end
