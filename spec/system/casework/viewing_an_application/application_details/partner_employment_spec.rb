require 'rails_helper'

RSpec.describe 'Viewing the employment details of the partner' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with employment details' do
    let(:card) do
      page.find('h2.govuk-summary-card__title', text: "Partner's employment").ancestor('div.govuk-summary-card')
    end

    it 'shows partners employment type' do
      within(card) do |card|
        expect(card).to have_summary_row "Partner's employment status", 'Not working'
      end
    end

    it 'does not show armed forces row if partner is not part of armed forces' do
      expect(page).to have_no_content('Partner in armed forces? No')
    end

    context 'when armed forces question has been answered' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'partner_in_armed_forces' => 'yes' } })
      end

      it 'shows if partner is part of armed forces' do
        within(card) do |card|
          expect(card).to have_summary_row 'Partner in armed forces?', 'Yes'
        end
      end
    end

    context 'when armed forces question is not answered' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'partner_in_armed_forces' => nil } })
      end

      it 'does not show armed forces details' do
        expect(page).to have_no_content('Partner in armed forces?')
      end
    end

    context 'when partner is employed and self employed' do
      let(:application_data) do
        JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
          'means_details' => {
            'income_details' => {
              'partner_employment_type' => %w[employed self_employed]
            }
          }
        )
      end

      it 'shows partners employment type' do
        within(card) do |card|
          expect(card).to have_summary_row "Partner's employment status", 'Employed and Self-employed'
        end
      end
    end
  end

  context 'with no income details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show income section' do
      expect(page).to have_no_content("Partner's employment")
    end
  end
end
