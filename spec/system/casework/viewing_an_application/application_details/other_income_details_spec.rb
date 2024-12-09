require 'rails_helper'

RSpec.describe 'Viewing the other income details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with other income details' do
    context 'when Other free text option is selected' do
      it 'shows manage without income details' do
        within_card('Other sources of income') do |card|
          expect(card).to have_summary_row('How client lives with no income', 'Other')
          expect(card).to have_summary_row('Details', 'Another way they manage')
        end
      end
    end

    context 'when partner is included in means assessment' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'partner' => { 'is_included_in_means_assessment' => true } })
      end

      it 'shows manage without income details' do
        within_card('Other sources of income') do |card|
          expect(card).to have_summary_row('How client and partner live with no income', 'Other')
          expect(card).to have_summary_row('Details', 'Another way they manage')
        end
      end
    end

    context 'when radio option selected' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'manage_without_income' => 'family',
                                                                      'manage_other_details' => 'other' } })
      end

      it 'shows manage without income details' do
        expect(page).to have_content('How client lives with no income They stay with family for free')
      end
    end
  end

  context 'with no income details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show income section' do
      expect(page).to have_no_content('Other sources of income')
    end
  end
end
