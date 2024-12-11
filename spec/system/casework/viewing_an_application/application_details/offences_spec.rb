require 'rails_helper'

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
        expect(card).to have_summary_row 'Offence type and class', 'Attempt robberyClass C'
        expect(card).to have_summary_row 'Offence date', '11/05/2020 – 12/05/2020 11/08/2020'
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
        expect(card).to have_summary_row 'Offence type and class', 'Non-listed offence, manually enteredNot determined'
        expect(card).to have_summary_row 'Offence date', '15/09/2020'
      end
    end
  end
end
