require 'rails_helper'

RSpec.describe "When viewing the partner's passporting benefit check details" do
  subject(:partner_card) do
    page.find('h2.govuk-summary-card__title', text: title).ancestor('div.govuk-summary-card')
  end

  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  let(:title) { 'Passporting benefit check: partner' }

  context 'with passporting benefit check details' do
    let(:application_data) do
      super().deep_merge('client_details' => { 'partner' => { 'is_included_in_means_assessment' => true,
                                                              'benefit_type' => 'universal_credit',
                                                              'benefit_check_status' => 'undetermined',
                                                              'confirm_details' => 'yes',
                                                              'has_benefit_evidence' => 'no' } })
    end

    it { expect(page).to have_content(title) }

    context 'when the benefit check was performed on the partner' do
      it 'shows whether partner has a passporting benefit' do
        within(partner_card) do
          expect(page).to have_content('Passporting benefit Universal Credit')
        end
      end

      it 'shows the passporting benefit check outcome rows' do # rubocop:disable RSpec/MultipleExpectations
        within(partner_card) do
          expect(page).to have_content('Passporting benefit check outcome No match - check details are correct')
          expect(page).to have_content('Confirmed details correct? Yes')
          expect(page).to have_content('Evidence can be provided? No')
        end
      end
    end

    context 'when partner did not go through benefit check' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'partner' => { 'is_included_in_means_assessment' => true,
                                                                'benefit_type' => nil,
                                                                'benefit_check_status' => 'no_check_required' } })
      end

      it 'displays the benefit check outcome as no check required' do
        within(partner_card) do
          expect(page).to have_content('Passporting benefit check outcome No check required')
        end
      end
    end

    context 'when applicant does not have partner' do
      let(:application_data) do
        super().deep_merge(
          'client_details' => {
            'partner' => { 'is_included_in_means_assessment' => false }
          }
        )
      end

      it 'does not show the partner passporting benefit check section' do
        expect(page).to have_no_content(title)
      end
    end
  end
end
