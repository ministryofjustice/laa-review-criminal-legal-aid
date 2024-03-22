require 'rails_helper'

RSpec.describe 'Viewing an applications address details' do
  include_context 'with stubbed application'

  before do
    visit '/'
    visit crime_application_path(application_id)
  end

  describe 'Home address' do
    subject(:home_address) { page.find('dt', text: 'Home address').find('+dd') }

    it 'shows the applicants postal address' do
      expect(home_address).to have_content('1 Road Village Some nice city SW1A 2AA United Kingdom')
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
                                                                    'country' => 'United Kingdom',
                                                                    'postcode' => 'EC2A 2AA',
                                                                    'lookup_id' => '1'
                                                                  } } })
      end

      it 'shows the correspondence address' do
        expect(correspondence_address).to have_content(
          'Other House Second Road London EC2A 2AA United Kingdom'
        )
      end
    end
  end
end
