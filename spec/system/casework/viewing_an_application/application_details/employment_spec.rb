require 'rails_helper'

RSpec.describe 'Viewing the employment details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with employment details' do
    let(:card) do
      page.find('h2.govuk-summary-card__title', text: 'Employment: client').ancestor('div.govuk-summary-card')
    end

    it { expect(page).to have_content('Employment: client') }

    it 'shows employment type' do
      within(card) do |card|
        expect(card).to have_summary_row "Client's employment status", 'Not working'
      end
    end

    it 'shows whether employment has ended in the last three months' do
      within(card) do |card|
        expect(card).to have_summary_row 'Employment ended in last 3 months?', 'Yes'
      end
    end

    it 'shows whether job was lost in custody and date details' do
      within(card) do |card|
        expect(card).to have_summary_row 'Did they lose their job as a result of being in custody?', 'Yes'
        expect(card).to have_summary_row 'When did they lose their job?', '01/09/2023'
      end
    end

    context 'when job was not lost in custody' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'lost_job_in_custody' => 'no',
                                                                      'date_job_lost' => nil } })
      end

      it 'does not show date custody lost details' do
        within(card) do |card|
          expect(card).to have_summary_row 'Did they lose their job as a result of being in custody?', 'No'
        end
        expect(page).to have_no_content('When did they lose their job?')
      end
    end

    it 'does not show armed forces row if client is not part of armed forces' do
      expect(page).to have_no_content('Client in armed forces? No')
    end

    context 'when armed forces question has been answered' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'client_in_armed_forces' => 'yes' } })
      end

      it 'shows if client is part of armed forces' do
        within(card) do |card|
          expect(card).to have_summary_row 'Client in armed forces?', 'Yes'
        end
      end
    end

    context 'when armed forces question is not answered' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'client_in_armed_forces' => nil } })
      end

      it 'does not show armed forces details' do
        expect(page).to have_no_content('Client in armed forces?')
      end
    end
  end

  context 'with no income details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show income section' do
      expect(page).to have_no_content('Employment: client')
    end
  end
end
