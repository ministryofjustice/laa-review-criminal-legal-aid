require 'rails_helper'

RSpec.describe 'When viewing the passporting benefit check details' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with passporting benefit check details' do
    it { expect(page).to have_content('Passporting Benefit Check') }

    it 'shows whether client has a passporting benefit' do
      expect(page).to have_content('Passporting Benefit Universal Credit')
    end

    it 'shows the passporting benefit check outcome rows' do # rubocop:disable RSpec/MultipleExpectations
      expect(page).to have_content('Passporting benefit check outcome No record of passporting benefit found')
      expect(page).to have_content('Confirmed client details correct? Yes')
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
        expect(page).not_to have_content('Passporting benefit check outcome No record of passporting benefit found')
        expect(page).not_to have_content('Confirmed client details correct? Yes')
        expect(page).not_to have_content('Evidence can be provided? No')
      end
    end
  end
end
