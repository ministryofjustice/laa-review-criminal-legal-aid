require 'rails_helper'

RSpec.describe 'Viewing an applications address details' do
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  before do
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
    ).to_return(body: application_data.to_json, status: 200)

    visit '/'
    visit crime_application_path(application_id)
  end

  describe 'Home address' do
    subject(:home_address) { page.find('dt', text: 'Home address').find('+dd') }

    it 'shows the applicants postal address' do
      expect(home_address).to have_content('1 Road Village Some nice city United Kingdom SW1A 2AA')
    end
  end

  describe 'Correspondence address' do
    subject(:correspondence_address) do
      page.find('dt', text: 'Correspondence address').find('+dd')
    end

    context 'when home address' do
      it { is_expected.to have_content 'Same as home address' }
    end

    context 'when providers office address' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'correspondence_address_type' => 'other_address',
                                                                  'correspondence_address' => {
                                                                    'address_line_one' => 'Other House',
                                                                    'address_line_two' => 'Second Road',
                                                                    'city' => 'London',
                                                                    'country' => 'London',
                                                                    'postcode' => 'EC2A 2AA'
                                                                  } } })
      end

      it 'shows the correspondence address' do
        expect(correspondence_address).to have_content(
          'Other House Second Road London London EC2A 2AA'
        )
      end
    end
  end
end
