require 'rails_helper'

RSpec.describe "When viewing the client's passporting benefit check details" do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with passporting benefit check details' do
    it { expect(page).to have_content('Passporting benefit check: client') }

    it 'shows whether client has a passporting benefit' do
      expect(page).to have_content('Passporting benefit Universal Credit')
    end

    it 'shows the passporting benefit check outcome rows' do # rubocop:disable RSpec/MultipleExpectations
      expect(page).to have_content('Passporting benefit check outcome No record of passporting benefit found')
      expect(page).to have_content('Confirmed details correct? Yes')
      expect(page).to have_content('Evidence can be provided? No')
    end

    context 'with no benefit check status' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'benefit_type' => nil,
                                                                  'benefit_check_status' => nil,
                                                                  'confirm_details' => nil,
                                                                  'has_benefit_evidence' => nil } })
      end

      it 'does not display the passporting benefit check outcome rows' do # rubocop:disable RSpec/MultipleExpectations
        expect(page).to have_no_content('Passporting benefit check outcome No record of passporting benefit found')
        expect(page).to have_no_content('Confirmed details correct? Yes')
        expect(page).to have_no_content('Evidence can be provided? No')
      end
    end

    context 'when applicant is under 18' do
      let(:application_data) { super().merge('means_passport' => ['on_age_under18']) }

      it 'does not show the passporting benefit check section' do
        expect(page).to have_no_content('Passporting benefit Check')
      end
    end

    context 'when application is not means tested' do
      let(:application_data) { super().merge('means_passport' => ['on_not_means_tested']) }

      it 'does not show the passporting benefit check section' do
        expect(page).to have_no_content('Passporting benefit Check')
      end
    end

    context 'when application is appeal no changes' do
      let(:application_data) do
        super().deep_merge('case_details' => {
                             'case_type' => 'appeal_to_crown_court',
                             'appeal_reference_number' => '123456'
                           })
      end

      it 'does not show the passporting benefit check section' do
        expect(page).to have_no_content('Passporting benefit Check')
      end
    end
  end
end
