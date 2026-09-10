module ProviderDataApi
  class MockGetOfficeDetails
    def self.call(_office_code)
      OfficeDetails.new(
        office: {
          addressLine1: '102 Petty France',
          addressLine2: nil,
          addressLine3: nil,
          addressLine4: nil,
          city: 'London',
          county: nil,
          postCode: 'SW1H 9AJ'
        },
        firm: { firmName: 'Mock Firm Ltd' }
      )
    end
  end
end
