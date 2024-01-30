require 'rails_helper'

RSpec.describe 'Viewing any additional information provided' do
  include_context 'with stubbed application'

  let(:additional_info_label) { 'Information from the provider' }

  before do
    visit crime_application_path(application_id)
  end

  context 'when additional information not provided' do
    it { expect(page).not_to have_content(additional_info_label) }
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
end
