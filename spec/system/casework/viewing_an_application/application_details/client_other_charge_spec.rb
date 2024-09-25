require 'rails_helper'

RSpec.describe 'Viewing the other charges for client in an application' do
  include_context 'with stubbed application'

  let(:application_data) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
      'case_details' => {
        'client_other_charge_in_progress' => client_other_charge_in_progress,
        'partner_other_charge_in_progress' => partner_other_charge_in_progress,
        'client_other_charge' => client_other_charge
      }
    )
  end

  let(:client_other_charge_in_progress) { nil }
  let(:partner_other_charge_in_progress) { nil }
  let(:client_other_charge) { nil }

  before do
    visit crime_application_path(application_id)
  end

  describe 'when no client other charge in progress' do
    let(:client_other_charge_in_progress) { nil }

    it 'does not show the card' do
      expect(page).not_to have_css('h2.govuk-summary-card__title', text: 'Other charges')
    end
  end

  describe 'when both client and partner `other charge in progress` questions are answered' do
    let(:client_other_charge_in_progress) { 'yes' }
    let(:partner_other_charge_in_progress) { 'no' }

    it 'shows the card with the right title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Other charges: client')
    end
  end

  describe 'when client other charge in progress' do
    subject(:client_other_charge_card) do
      page.find('h2.govuk-summary-card__title', text: 'Other charges')
          .ancestor('div.govuk-summary-card')
    end

    context 'when no other charge details' do
      let(:client_other_charge_in_progress) { 'no' }
      let(:client_other_charge) { nil }

      it 'shows other charges answer' do
        within(client_other_charge_card) do |card|
          expect(card).to have_summary_row 'Other charges?', 'No'
        end
      end
    end

    context 'when other charge details are present' do
      let(:client_other_charge_in_progress) { 'yes' }
      let(:client_other_charge) do
        {
          charge: 'Theft',
          hearing_court_name: "Cardiff Magistrates' Court",
          next_hearing_date: '2025-01-15',
        }
      end

      it 'shows other charges details' do # rubocop:disable RSpec/MultipleExpectations
        within(client_other_charge_card) do |card|
          expect(card).to have_summary_row 'Other charges?', 'Yes'
          expect(card).to have_summary_row 'What is the charge?', 'Theft'
          expect(card).to have_summary_row 'Court', "Cardiff Magistrates' Court"
          expect(card).to have_summary_row 'Next hearing', '15/01/2025'
        end
      end
    end
  end
end
