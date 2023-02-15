require 'rails_helper'

RSpec.describe 'Viewing an applications address details' do
  include_context 'with stubbed search'
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
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
    subject(:corresspondence_address) do
      page.find('dt', text: 'Correspondence address').find('+dd')
    end

    context 'when home address' do
      it { is_expected.to have_content 'Same as home address' }
    end

    context 'when providers office address' do
      let(:application_id) { '5aa4c689-6fb5-47ff-9567-5efe7f8ac211' }

      it 'shows the correspondence address' do
        expect(corresspondence_address).to have_content(
          'Other House Second Road London London EC2A 2AA'
        )
      end
    end
  end
end
