require 'rails_helper'

RSpec.describe 'Viewing the housing payments of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with housing payments details' do
    it { expect(page).to have_content('Employment') }

    context 'when housing payment is mortgage' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'lost_job_in_custody' => 'no',
                                                                      'date_job_lost' => nil } })
      end

      it 'does not show date custody lost details' do
        expect(page).to have_content('Did they lose their job as a result of being in custody? No')
        expect(page).not_to have_content('When did they lose their job?')
      end
    end

    context 'when housing payment is rent' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'lost_job_in_custody' => 'no',
                                                                      'date_job_lost' => nil } })
      end

      it 'does not show date custody lost details' do
        expect(page).to have_content('Did they lose their job as a result of being in custody? No')
        expect(page).not_to have_content('When did they lose their job?')
      end
    end

    context 'when housing payment is board_and_lodging' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'lost_job_in_custody' => 'no',
                                                                      'date_job_lost' => nil } })
      end

      it 'does not show date custody lost details' do
        expect(page).to have_content('Did they lose their job as a result of being in custody? No')
        expect(page).not_to have_content('When did they lose their job?')
      end
    end

    context 'when council tax paymet is provided' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'income_details' => { 'lost_job_in_custody' => 'no',
                                                                      'date_job_lost' => nil } })
      end

      it 'does not show date custody lost details' do
        expect(page).to have_content('Did they lose their job as a result of being in custody? No')
        expect(page).not_to have_content('When did they lose their job?')
      end
    end
  end

  context 'with no housing payments details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show income section' do
      expect(page).not_to have_content('Employment')
    end
  end
end
