require 'rails_helper'

RSpec.describe 'Viewing any additional information provided' do
  include_context 'with stubbed application'

  let(:additional_info_label) { 'Information from the provider' }

  before do
    visit crime_application_path(application_id)
  end

  context 'when additional information not provided' do
    it { expect(page).to have_no_content(additional_info_label) }
  end

  context 'when additional information provided' do
    let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(additional_information:) }

    let(:additional_information) do
      <<STRING
        First line of info.
        Second line of info.

        Last line of info.
STRING
    end

    let(:inset_text) { page.find('.govuk-inset-text') }

    it 'shows the additional information as inset text with the correct heading' do
      expect(inset_text).to have_css('h2', text: additional_info_label)
    end

    it 'shows the application\'s additional information in simple format' do
      expect(inset_text).to have_css('p', text: 'First line of info.')
      expect(inset_text).to have_css('p', text: 'Last line of info.')
    end
  end

  context 'with additional information' do
    let(:application_data) do
      super().deep_merge('additional_information' => 'Shown top and bottom of page')
    end

    it 'shows the additional information as `information from the provider`' do
      inset = find(:xpath, "//div[@class='govuk-inset-text']")

      expect(inset).to have_content("Information from the provider\nShown top and bottom of page")
    end

    it 'shows the additional information as `further information`' do
      further_information = find(
        :xpath,
        "//div[@class='govuk-summary-list__row'][contains(dd, 'Shown top and bottom of page')]"
      )

      expect(further_information).not_to be_nil
    end
  end
end
