require 'rails_helper'

RSpec.describe 'Viewing the other capital details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when user was not asked about frozen income or assets in capital' do
    it { expect(page).not_to have_content('Other capital') }
  end

  context 'when user was asked about frozen income or assets in capital' do
    let(:application_data) do
      super().deep_merge('means_details' => { 'capital_details' => { 'has_frozen_income_or_assets' => 'no' } })
    end

    it { expect(page).to have_content('Other capital') }

    it 'shows whether client has income, savings or assets under a restraint or freezing order' do
      expect(page).to have_content('Has income, savings or assets under a restraint or freezing order? No')
    end
  end
end
