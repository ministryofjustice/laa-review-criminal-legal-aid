require 'rails_helper'

RSpec.describe 'Viewing the investments of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when client has investments' do
    let(:means_details) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read) }

    let(:application_data) do
      super().deep_merge('means_details' => means_details)
    end

    it 'shows the investments section' do
      expect(page).to have_css('h2.govuk-heading-m', text: 'Investments')
    end

    it 'shows the investments with correct title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Unit trust')
    end

    describe 'an investments card' do
      subject(:investment_card) do
        page.find('h2.govuk-summary-card__title', text: 'Unit trust').ancestor('div.govuk-summary-card')
      end

      it 'shows investments details' do # rubocop:disable RSpec/MultipleExpectations
        within(investment_card) do |card|
          expect(card).to have_summary_row 'Describe the investment', 'Details of investment'
          expect(card).to have_summary_row 'What is the value of the investment?', '£2.00'
          expect(card).to have_summary_row 'Whose name is the investment in?', 'Partner'
        end
      end
    end
  end

  context 'when client does not have investments' do
    let(:application_data) do
      super().deep_merge('case_details' => { 'case_type' => 'either_way' },
                         'means_details' => { 'capital_details' => { 'investments' => [] } })
    end

    describe 'an absent answer investments card' do
      subject(:investment_card) do
        page.find('h2.govuk-summary-card__title', text: 'Investments').ancestor('div.govuk-summary-card')
      end

      it 'shows absent answer investments details' do
        within(investment_card) do |card|
          expect(card).to have_summary_row 'Does client have any investments?', 'None'
        end
      end
    end
  end
end
