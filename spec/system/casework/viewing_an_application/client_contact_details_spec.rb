require 'rails_helper'

RSpec.describe 'Viewing Client contact details' do
  include_context 'with stubbed application'

  before do
    visit '/'
    visit crime_application_path(application_id)
  end

  describe 'Client details Home address' do
    context 'when home address is present' do
      subject(:home_address) do
        within summary_card('Client contact details') do
          page.first('dt', text: 'Home address').find('+dd')
        end
      end

      it 'shows the applicants postal address' do
        expect(home_address).to have_content('1 Road Village Some nice city SW1A 2AA United Kingdom')
      end
    end

    context 'when home address question was not asked' do
      let(:application_data) do
        super().deep_merge('client_details' =>
                             { 'applicant' => { 'residence_type' => 'none',
                                                'relationship_to_owner_of_usual_home_address' => nil },
                               'partner' => { 'home_address' => nil } })
      end

      it 'does not show the home address' do
        within summary_card('Client contact details') do
          expect(page).to have_no_content('Home address')
        end
      end
    end
  end

  describe 'Correspondence address' do
    subject(:correspondence_address) do
      within summary_card('Client contact details') do
        page.first('dt', text: 'Correspondence').find('+dd')
      end
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

  describe 'Correspondence preference language' do
    context 'when preferred language is default' do
      it 'does not display correspondence preference language row' do
        expect(summary_card('Client contact details')).not_to have_content('Correspondence requested in Welsh? Yes')
      end
    end

    context 'when preferred language is welsh' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'preferred_correspondence_language' => 'cy' } })
      end

      it 'does display correspondence preference language row' do
        expect(summary_card('Client contact details')).to have_content('Correspondence requested in Welsh? Yes')
      end
    end
  end
end
