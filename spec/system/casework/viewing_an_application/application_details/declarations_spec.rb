require 'rails_helper'

RSpec.describe 'Viewing the declarations on an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when application has no partner declaration details' do
    let(:application_data) do
      super().deep_merge('provider_details' => { 'legal_rep_has_partner_declaration' => nil,
                                                  'legal_rep_no_partner_declaration_reason' => nil })
    end

    it 'shows the Declarations section with correct title' do
      expect(page).to have_css('h2.govuk-heading-l', text: 'Declarations')
    end

    it 'shows the Declarations card with correct title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Declarations')
    end

    describe 'a Declarations card' do
      subject(:declarations_card) do
        page.find(
          'h2.govuk-summary-card__title',
          text: 'Declarations'
        ).ancestor('div.govuk-summary-card')
      end

      it 'shows Declarations details' do # rubocop:disable RSpec/MultipleExpectations
        within(declarations_card) do |card|
          expect(card).to have_summary_row 'Declaration from client?', 'Yes'
          expect(card).to have_no_css('dt.govuk-summary-list__key', text: 'Declaration from partner?')
          expect(card).to have_no_css('dt.govuk-summary-list__key', text: 'Reason for no partner declaration')
        end
      end
    end
  end

  context 'when application does have partner declaration details' do
    let(:application_data) do
      super().deep_merge('provider_details' => { 'legal_rep_has_partner_declaration' => 'no',
                                                  'no_partner_declaration_reason' => 'A reason' })
    end

    it 'shows the National Savings Certificates with correct title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Declarations')
    end

    describe 'a Declarations card' do
      subject(:declarations_card) do
        page.find(
          'h2.govuk-summary-card__title',
          text: 'Declarations'
        ).ancestor('div.govuk-summary-card')
      end

      it 'shows Declarations details' do # rubocop:disable RSpec/MultipleExpectations
        within(declarations_card) do |card|
          expect(card).to have_summary_row 'Declaration from client?', 'Yes'
          expect(card).to have_summary_row 'Declaration from partner?', 'No'
          expect(card).to have_summary_row 'Reason for no partner declaration', 'A reason'
        end
      end
    end
  end
end
