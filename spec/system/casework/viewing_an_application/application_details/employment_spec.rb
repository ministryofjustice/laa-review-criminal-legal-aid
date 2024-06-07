require 'rails_helper'

RSpec.describe 'Viewing the employment details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with employment details' do
    it { expect(page).to have_content('Employment') }

    it 'shows employment type' do
      expect(page).to have_content("Client's employment status Not working")
    end

    it 'shows whether employment has ended in the last three months' do
      expect(page).to have_content('Have they ended employment in the last 3 months? Yes')
    end

    it 'shows whether job was lost in custody and date details' do
      expect(page).to have_content('Did they lose their job as a result of being in custody? Yes')
      expect(page).to have_content('When did they lose their job? 01/09/2023')
    end

    context 'when job was not lost in custody' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'lost_job_in_custody' => 'no',
                                                                      'date_job_lost' => nil } })
      end

      it 'does not show date custody lost details' do
        expect(page).to have_content('Did they lose their job as a result of being in custody? No')
        expect(page).to have_no_content('When did they lose their job?')
      end
    end
  end

  context 'with no income details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show income section' do
      expect(page).to have_no_content('Employment')
    end
  end
end
