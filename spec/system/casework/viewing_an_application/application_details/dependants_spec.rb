require 'rails_helper'

RSpec.describe 'Viewing the dependants details of an application' do
  include_context 'with stubbed application' do
    before do
      visit crime_application_path(application_id)
    end

    let(:application_data) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
        'means_details' => {
          'income_details' => {
            'client_has_dependants' => client_has_dependants,
            'dependants' => dependants
          }
        }
      )
    end

    let(:title_text) { 'Dependants who live with the client' }

    context 'with dependants' do
      let(:dependants) { [{ age: 1 }, { age: 5 }] }
      let(:client_has_dependants) { 'yes' }

      it 'shows dependants heading' do
        expect(page).to have_content(title_text)
      end

      it 'shows dependants grouped by age range' do
        expect(page).to have_content('Number of dependants aged 0 to 1 on next birthday 1')
        expect(page).to have_content('Number of dependants aged 5 to 7 on next birthday 1')
      end
    end

    context 'with no dependants' do
      let(:dependants) { [] }
      let(:client_has_dependants) { 'no' }

      it 'shows dependants heading' do
        expect(page).to have_content(title_text)
      end

      it 'shows no dependants' do
        expect(page).to have_content('Has dependants? No')
      end
    end

    context 'when question not answered' do
      let(:dependants) { [] }
      let(:client_has_dependants) { nil }

      it 'does not show the dependants heading' do
        expect(page).not_to have_content(title_text)
      end
    end
  end
end
