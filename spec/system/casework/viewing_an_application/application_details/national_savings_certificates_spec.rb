require 'rails_helper'

RSpec.describe 'Viewing the National Savings Certificates of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when client has National Savings Certificates' do
    let(:means_details) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read) }

    let(:application_data) do
      super().deep_merge('means_details' => means_details)
    end

    it 'shows the National Savings Certificates with correct title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'National Savings Certificate')
    end

    describe 'a National Savings Certificates card' do
      subject(:certificate_card) do
        page.find(
          'h2.govuk-summary-card__title',
          text: 'National Savings Certificate'
        ).ancestor('div.govuk-summary-card')
      end

      it 'shows National Savings Certificates details' do # rubocop:disable RSpec/MultipleExpectations
        within(certificate_card) do |card|
          expect(card).to have_summary_row 'What is the customer number or holder number?', 'A123'
          expect(card).to have_summary_row 'What is the certificate number?', 'B456'
          expect(card).to have_summary_row 'What is the value of the certificate?', '£200.10'
          expect(card).to have_summary_row 'Who owns the certificate?', 'Partner'
        end
      end
    end
  end

  context 'when client does not have national savings certificates' do
    let(:application_data) do
      super().deep_merge('case_details' => { 'case_type' => 'either_way' },
                         'means_details' => { 'capital_details' => { 'national_savings_certificates' => [],
                                                                     'has_national_savings_certificates' => 'no' } })
    end

    describe 'a no national savings certificates card' do
      subject(:certificates_card) do
        page.find('h2.govuk-summary-card__title',
                  text: 'National Savings Certificates').ancestor('div.govuk-summary-card')
      end

      it 'shows absent answer national savings certificates details' do
        within(certificates_card) do |card|
          expect(card).to have_summary_row 'Any National Savings Certificates?', 'No'
        end
      end
    end
  end
end
