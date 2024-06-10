require 'rails_helper'

RSpec.describe "When viewing the partner's passporting benefit check details" do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with passporting benefit check details' do
    it { expect(page).to have_content('Passporting benefit check: partner') }

    context 'when the benefit check was performed on the partner' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'has_partner' => 'yes',
                                                                  'benefit_type' => 'none',
                                                                  'benefit_check_status' => 'no_check_required',
                                                                  'confirm_details' => nil,
                                                                  'has_benefit_evidence' => nil },
                                                 'partner' => { 'benefit_type' => 'universal_credit',
                                                                'benefit_check_status' => 'undetermined',
                                                                'confirm_details' => 'yes',
                                                                'has_benefit_evidence' => 'no' } })
      end

      it 'shows whether partner has a passporting benefit' do
        expect(page).to have_content('Passporting Benefit Universal Credit')
      end

      it 'shows the passporting benefit check outcome rows' do # rubocop:disable RSpec/MultipleExpectations
        expect(page).to have_content('Passporting benefit check outcome No match - check details are correct')
        expect(page).to have_content('Confirmed details correct? Yes')
        expect(page).to have_content('Evidence can be provided? No')
      end
    end

    context 'when partner did not go through benefit check' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'has_partner' => 'yes',
                                                                  'benefit_type' => 'universal_credit' },
                                                 'partner' => { 'benefit_type' => nil,
                                                                'benefit_check_status' => 'no_check_required' } })
      end

      it 'displays the benefit check outcome as no check required' do
        expect(page).to have_content('Passporting benefit check outcome No check required')
      end
    end

    context 'when applicant does not have partner' do
      let(:application_data) { super().deep_merge('client_details' => { 'applicant' => { 'has_partner' => 'no' }})}

      it 'does not show the partner passporting benefit check section' do
        expect(page).not_to have_content('Passporting Benefit Check: partner')
      end
    end
  end
end
