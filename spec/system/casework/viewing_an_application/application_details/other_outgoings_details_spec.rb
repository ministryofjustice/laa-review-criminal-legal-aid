require 'rails_helper'

RSpec.describe 'Viewing the other outgoings details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with employment details' do
    it { expect(page).to have_content('Other outgoings') }

    it 'shows whether income rate across threshold' do
      expect(page).to have_content("Client's employment status Not working")
    end

    it 'shows if outgoings is more than income and how they manage' do
      expect(page).to have_content("Are client's outgoings more than their income? Yes")
      how_manage_question = 'How does client manage if their outgoings are more than their income?'
      expect(page).to have_content("#{how_manage_question}\nA description of how they manage")
    end

    context 'when job was not lost in custody' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'outgoings_details' => { 'outgoings_more_than_income' => 'no',
                                                                      'how_manage' => nil } })
      end

      it 'does not show how they manage details' do
        expect(page).to have_content("Are client's outgoings more than their income? No")
        expect(page).not_to have_content('How does client manage if their outgoings are more than their income?')
      end
    end
  end

  context 'with no income details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show income section' do
      expect(page).not_to have_content('Employment')
    end
  end
end
