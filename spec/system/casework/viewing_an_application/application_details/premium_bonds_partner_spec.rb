require 'rails_helper'

RSpec.describe 'Viewing the Premium Bond details of the partner' do
  include_context 'with stubbed application'
  let(:means_details) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read) }

  before do
    visit crime_application_path(application_id)
  end

  context 'when the partner has premium bonds' do
    # rubocop:disable Layout/LineLength
    let(:application_data) do
      super().deep_merge('means_details' => { 'capital_details' => { 'has_premium_bonds' => 'no',
                                                                     'premium_bonds_total_value' => nil,
                                                                     'premium_bonds_holder_number' => nil,
                                                                     'partner_has_premium_bonds' => 'yes',
                                                                     'partner_premium_bonds_total_value' => 200_000,
                                                                     'partner_premium_bonds_holder_number' => '89548A' } })
    end
    # rubocop:enable Layout/LineLength

    it 'shows the partner premium bonds card' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Premium Bonds: partner')
    end

    describe 'a premium bonds card' do
      subject(:premium_bonds_card) do
        page.find('h2.govuk-summary-card__title', text: 'Premium Bonds: partner').ancestor('div.govuk-summary-card')
      end

      it 'shows the Premium bonds details' do # rubocop:disable RSpec/MultipleExpectations
        within(premium_bonds_card) do |card|
          expect(card).to have_summary_row 'Any Premium Bonds?', 'Yes'
          expect(card).to have_summary_row 'Total value', '£2,000.00'
          expect(card).to have_summary_row 'Holder number', '89548A'
        end
      end
    end
  end

  context 'when the partner has no premium bonds' do
    let(:means_details) { super().deep_merge('capital_details' => { 'partner_has_premium_bonds' => 'no' }) }

    let(:application_data) do
      super().deep_merge('means_details' => means_details)
    end

    it 'shows the partner premium bonds card' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Premium Bonds: partner')
    end

    describe 'a premium bonds card' do
      subject(:premium_bonds_card) do
        page.find('h2.govuk-summary-card__title', text: 'Premium Bonds: partner').ancestor('div.govuk-summary-card')
      end

      it 'only shows the first question' do
        within(premium_bonds_card) do |card|
          expect(card).to have_summary_row 'Any Premium Bonds?', 'No'
          expect(card.all('dd').size).to be 1
        end
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
