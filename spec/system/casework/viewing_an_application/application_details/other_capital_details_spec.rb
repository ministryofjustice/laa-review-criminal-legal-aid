require 'rails_helper'

RSpec.describe 'Viewing the other capital details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when user was not asked about frozen income or assets in capital' do
    it { expect(page).to have_content('Other capital') }
  end

  context 'when user was asked about frozen income or assets in capital' do
    let(:application_data) do
      super().deep_merge(
        'means_details' => {
          'capital_details' => {
            'has_frozen_income_or_assets' => 'yes',
            'frozen_income_or_assets_subject' => 'client'
          }
        }
      )
    end

    it { expect(page).to have_content('Other capital') }

    it 'shows whether client has income, savings or assets under a restraint or freezing order' do
      within('.govuk-summary-card', text: 'Other capital') do
        expect(page).to have_content(
          'Income, savings or assets under a restraint or freezing order Yes'
        )
      end
    end

    it 'shows who the restraint or freezing order relates to' do
      within('.govuk-summary-card', text: 'Other capital') do
        expect(page).to have_content(
          'Who does the restraint or freezing order relate to? Client'
        )
      end
    end
  end
end
