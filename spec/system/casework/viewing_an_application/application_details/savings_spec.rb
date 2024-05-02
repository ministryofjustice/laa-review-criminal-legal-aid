require 'rails_helper'

RSpec.describe 'Viewing the savings of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when client has savings' do
    let(:means_details) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read) }

    let(:application_data) do
      super().deep_merge('means_details' => means_details)
    end

    it 'shows the savings section' do
      expect(page).to have_css('h2.govuk-heading-l', text: 'Savings')
    end

    it 'shows the savings with correct title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Bank account')
    end

    describe 'a savings card' do
      subject(:saving_card) do
        page.find('h2.govuk-summary-card__title', text: 'Bank account').ancestor('div.govuk-summary-card')
      end

      it 'shows savings details' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
        within(saving_card) do |card|
          expect(card).to have_summary_row 'Name of bank, building society or other holder of the savings', 'Halifax'
          expect(card).to have_summary_row 'Sort code or branch name', '123456'
          expect(card).to have_summary_row 'Account number', '12345678'
          expect(card).to have_summary_row 'Account balance', '£2.00'
          expect(card).to have_summary_row 'Is the account overdrawn?', 'Yes'
          expect(card).to have_summary_row 'Are client’s wages or benefits paid into this account?', 'Yes'
          expect(card).to have_summary_row 'Name the account is in', 'Client'
        end
      end
    end
  end

  context 'when client does not have savings' do
    let(:application_data) do
      super().deep_merge('case_details' => { 'case_type' => 'either_way' },
                         'means_details' => { 'capital_details' => { 'savings' => [], 'has_no_savings' => 'yes' } })
    end

    describe 'a no savings card' do
      subject(:saving_card) do
        page.first('h2.govuk-summary-card__title', text: 'Savings').ancestor('div.govuk-summary-card')
      end

      it 'shows absent answer savings details' do
        within(saving_card) do |card|
          expect(card).to have_summary_row 'Which savings does the client have inside or outside the UK?', 'None'
        end
      end
    end
  end
end
