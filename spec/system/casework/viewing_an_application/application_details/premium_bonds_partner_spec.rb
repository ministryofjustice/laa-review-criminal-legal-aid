require 'rails_helper'

RSpec.describe 'Viewing the Premium Bond details of the partner' do
  include_context 'with stubbed application'

  let(:partner_included?) { true }

  before do
    visit crime_application_path(application_id)
  end

  context 'when the partner has premium bonds but the client does not' do
    subject(:premium_bonds_card) do
      page.find('h2.govuk-summary-card__title', text: 'Premium Bonds').ancestor('div.govuk-summary-card')
    end

    let(:capital_details) do
      {
        'has_premium_bonds' => 'no',
        'premium_bonds_total_value' => nil,
        'premium_bonds_holder_number' => nil,
        'partner_has_premium_bonds' => 'yes',
        'partner_premium_bonds_total_value' => 200_000,
        'partner_premium_bonds_holder_number' => '89548A'
      }
    end

    it 'shows the Premium bonds details' do # rubocop:disable RSpec/MultipleExpectations
      within(premium_bonds_card) do |card|
        expect(card).to have_summary_row 'Premium Bonds: client', 'No'
        expect(card).to have_summary_row 'Premium Bonds: partner', 'Yes'
        expect(card).to have_summary_row 'Holder number: partner', '89548A'
        expect(card).to have_summary_row 'Total value', '£2,000.00'
      end
    end
  end

  context 'when both partner and client have premium bonds' do
    subject(:premium_bonds_card) do
      page.find('h2.govuk-summary-card__title', text: 'Premium Bonds').ancestor('div.govuk-summary-card')
    end

    let(:capital_details) do
      {
        'partner_has_premium_bonds' => 'yes',
        'partner_premium_bonds_total_value' => 200_001,
        'partner_premium_bonds_holder_number' => '89548A'
      }
    end

    it 'shows the Premium bonds details' do # rubocop:disable RSpec/MultipleExpectations
      within(premium_bonds_card) do |card|
        expect(card).to have_summary_row 'Premium Bonds: client', 'Yes'
        expect(card).to have_summary_row 'Holder number: client', '123568A'
        expect(card).to have_summary_row 'Premium Bonds: partner', 'Yes'
        expect(card).to have_summary_row 'Holder number: partner', '89548A'
        expect(card).to have_summary_row 'Total value', '£3,000.01'
      end
    end
  end

  context 'when neither the partner or the client have premium bonds' do
    subject(:premium_bonds_card) do
      page.find('h2.govuk-summary-card__title', text: 'Premium Bonds').ancestor('div.govuk-summary-card')
    end

    let(:capital_details) do
      {
        'has_premium_bonds' => 'no',
        'premium_bonds_total_value' => nil,
        'premium_bonds_holder_number' => nil,
        'partner_has_premium_bonds' => 'no',
        'partner_premium_bonds_total_value' => 200_000,
        'partner_premium_bonds_holder_number' => '89548A'
      }
    end

    it 'only shows the first question' do # rubocop:disable RSpec/MultipleExpectations
      within(premium_bonds_card) do |card|
        expect(card).to have_summary_row 'Premium Bonds: client', 'No'
        expect(card).to have_summary_row 'Premium Bonds: partner', 'No'
        expect(card.all('dd').size).to be 2
      end
    end
  end

  context 'when client was not shown premium bonds questions' do
    let(:means_details) { super().deep_merge('capital_details' => { 'has_premium_bonds' => nil }) }

    let(:application_data) do
      super().deep_merge('means_details' => means_details)
    end

    it 'does not show the Premium Bonds section' do
      expect(page).to have_no_css('h2.govuk-heading-l', text: 'Premium Bonds')
    end
  end
end
