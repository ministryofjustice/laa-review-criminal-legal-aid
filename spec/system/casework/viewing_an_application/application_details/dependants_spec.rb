require 'rails_helper'

RSpec.describe 'Viewing the dependants details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with dependants' do
    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => { 'dependants' => [{ age: 1 }, { age: 5 }] } })
    end

    it 'shows dependants heading' do
      expect(page).to have_content('Dependants who live with the client')
    end

    it 'shows dependants grouped by age range' do
      expect(page).to have_content('Number of dependants aged 0 to 1 on next birthday 1')
      expect(page).to have_content('Number of dependants aged 5 to 7 on next birthday 1')
    end
  end

  context 'with no dependants' do
    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => { 'dependants' => [] } })
    end

    it 'shows dependants heading' do
      expect(page).to have_content('Dependants who live with the client')
    end

    it 'shows no dependants' do
      expect(page).to have_content('Has dependants? No')
    end
  end

  context 'with not shown dependants screen' do
    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => { 'dependants' => nil } })
    end

    it 'does not show dependants section' do
      expect(page).not_to have_content('Dependants who live with the client')
    end
  end
end
