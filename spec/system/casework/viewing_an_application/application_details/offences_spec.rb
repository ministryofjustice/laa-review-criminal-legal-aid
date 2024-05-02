require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations
RSpec.describe 'Viewing the offences listed in an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  describe 'displaying an offence with class' do
    subject(:offence_card) do
      page.find('h2.govuk-summary-card__title', text: 'Offence 1')
          .ancestor('div.govuk-summary-card')
    end

    it 'shows offence details' do
      within(offence_card) do |card|
        expect(card).to have_summary_row 'Type', 'Attempt robbery'
        expect(card).to have_summary_row 'Class', 'Class C'
        expect(card).to have_summary_row 'Date', '11/05/2020 – 12/05/2020 11/08/2020'
      end
    end
  end

  describe 'displaying an offence without a class' do
    subject(:offence_card) do
      page.find('h2.govuk-summary-card__title', text: 'Offence 2')
          .ancestor('div.govuk-summary-card')
    end

    it 'shows offence details' do
      within(offence_card) do |card|
        expect(card).to have_summary_row 'Type', 'Non-listed offence, manually entered'
        expect(card).to have_summary_row 'Class', 'Not determined'
        expect(card).to have_summary_row 'Date', '15/09/2020'
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
