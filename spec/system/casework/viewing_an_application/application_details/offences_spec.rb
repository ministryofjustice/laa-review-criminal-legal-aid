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

    it 'shows offence details' do # rubocop:disable RSpec/MultipleExpectations
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

    it 'shows offence details' do # rubocop:disable RSpec/MultipleExpectations
      within(offence_card) do |card|
        expect(card).to have_summary_row 'Type', 'Non-listed offence, manually entered'
        expect(card).to have_summary_row 'Class', 'Not determined'
        expect(card).to have_summary_row 'Date', '15/09/2020'
      end
    end
  end

  describe 'displaying an offence with multiple dates' do
    subject(:offence_card) do
      page.find('h2.govuk-summary-card__title', text: 'Offence 1')
          .ancestor('div.govuk-summary-card')
    end

    it 'shows offence details' do # rubocop:disable RSpec/MultipleExpectations
      within(offence_card) do |card|
        within(card.find('.govuk-summary-list__row', text: 'Dates')) do
          expect(find('.govuk-summary-list__key').text).to eq('Dates')

          value_text = find('.govuk-summary-list__value').text
          expect(value_text).to include('11/05/2020 – 12/05/2020')
          expect(value_text).to include('11/08/2020')
        end
      end
    end
  end

  describe 'displaying an offence with a single date' do
    subject(:offence_card) do
      page.find('h2.govuk-summary-card__title', text: 'Offence 2')
          .ancestor('div.govuk-summary-card')
    end

    it 'shows offence details' do
      within(offence_card) do |card|
        within(card.find('.govuk-summary-list__row', text: 'Date')) do
          expect(find('.govuk-summary-list__key').text).to eq('Date')
          expect(find('.govuk-summary-list__value').text).to include('15/09/2020')
        end
      end
    end
  end
end
