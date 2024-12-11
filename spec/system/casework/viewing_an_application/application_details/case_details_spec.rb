require 'rails_helper'

RSpec.describe 'When viewing case details' do
  include_context 'with stubbed application'
  let(:case_type) { 'indictable' }
  let(:card) do
    page.find('h2.govuk-summary-card__title', text: 'Case details').ancestor('div.govuk-summary-card')
  end

  before do
    visit crime_application_path(application_id)
  end

  context 'with case details' do
    context 'when case type is not an appeal type' do
      let(:application_data) do
        super().deep_merge('case_details' => { 'case_type' => 'either_way' })
      end

      it 'does not show appeal lodged date section' do
        expect(page).to have_no_content('Appeal lodged')
      end
    end

    context 'when case type is an appeal' do
      let(:case_type) { 'appeal_to_crown_court' }

      it 'shows appeal lodged date' do
        expect(page).to have_content('Date the appeal was lodged 25/10/2021')
      end

      context 'when original app submitted is true' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'appeal_original_app_submitted' => 'yes' })
        end

        it 'shows the original app submitted question' do
          expect(page).to have_content('Legal aid application for original case? Yes')
        end

        it 'shows the changes to financial circumstances question' do
          expect(page).to have_content('Changes to financial circumstances since original application?')
        end
      end

      context 'when original app submitted is false' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'appeal_original_app_submitted' => 'no' })
        end

        it 'shows the original app submitted question' do
          expect(page).to have_content('Legal aid application for original case? No')
        end

        it 'does not show changes to financial circumstances question' do
          expect(page).to have_no_content('Changes to financial circumstances')
        end

        it 'does not show MAAT ID or USN' do
          expect(page).to have_no_content('Original application MAAT ID')
          expect(page).to have_no_content('Original application USN')
        end
      end

      context 'when there are no changes in financial circumstances and MAAT ID is provided' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'appeal_original_app_submitted' => 'yes',
                                                 'appeal_financial_circumstances_changed' => 'no',
                                                 'appeal_maat_id' => '123456' })
        end

        it 'shows changes to financial circumstances question' do
          expect(page).to have_content('Changes to financial circumstances since original application? No')
        end

        it 'displays the MAAT ID' do
          expect(page).to have_content('Original application MAAT ID 123456')
          expect(page).to have_no_content('Original application USN')
        end
      end

      context 'when there are no changes in financial circumstances and USN is provided' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'appeal_original_app_submitted' => 'yes',
                                                 'appeal_financial_circumstances_changed' => 'no',
                                                 'appeal_usn' => '654321' })
        end

        it 'shows changes to financial circumstances question' do
          expect(page).to have_content('Changes to financial circumstances since original application? No')
        end

        it 'displays the USN' do
          expect(page).to have_no_content('Original application MAAT ID')
          expect(page).to have_content('Original application USN 654321')
        end
      end
    end

    context 'when case type is an appeal with changes to financial circumstances with a new application' do
      let(:application_data) do
        super().deep_merge('case_details' => { 'case_type' => 'appeal_to_crown_court_with_changes',
                                               'appeal_original_app_submitted' => 'yes',
                                               'appeal_financial_circumstances_changed' => 'yes',
                                               'appeal_with_changes_details' => 'Some details' })
      end

      it 'shows appeal lodged date' do
        expect(page).to have_content('Date the appeal was lodged 25/10/2021')
      end

      it 'shows changes to financial circumstances question' do
        expect(page).to have_content('Changes to financial circumstances since original application? Yes')
      end

      it 'shows changes to details' do
        expect(page).to have_content('Changes in the client’s financial circumstances Some details')
      end

      it 'does not show MAAT ID or USN' do
        expect(page).to have_no_content('Original application MAAT ID')
        expect(page).to have_no_content('Original application USN')
      end
    end

    context 'when case type is appeal and application is a change in financial circumstances' do
      let(:application_data) do
        super().deep_merge('application_type' => 'change_in_financial_circumstances',
                           'pre_cifc_reason' => 'Has a new high paying job',
                           'pre_cifc_reference_number' => 'pre_cifc_usn',
                           'pre_cifc_usn' => 'MY199992',
                           'case_details' => { 'case_type' => 'appeal_to_crown_court',
                                               'appeal_original_app_submitted' => 'yes',
                                               'appeal_with_changes_details' => nil })
      end

      it 'does not show original MAAT ID or USN' do
        expect(page).to have_no_content('Original application MAAT ID')
      end

      it 'does not show changes to financial circumstances question' do
        expect(page).to have_no_content('Changes to financial circumstances since original application?')
      end
    end

    context 'when case concluded' do
      let(:application_data) do
        super().deep_merge('case_details' => case_details)
      end

      context 'when has case concluded question was never asked' do
        let(:case_details) do
          { 'has_case_concluded' => nil }
        end

        it 'hides has case concluded question' do
          expect(page).to have_no_content('Has the case concluded?')
        end
      end

      context 'when case is concluded' do
        let(:case_details) do
          { 'has_case_concluded' => 'yes', 'date_case_concluded' => '2021-10-25' }
        end

        it 'shows has case concluded as yes' do
          expect(page).to have_content('Case concluded? Yes')
          expect(page).to have_content('When the case concluded 25/10/2021')
        end
      end

      context 'when case is not concluded' do
        let(:case_details) do
          { 'has_case_concluded' => 'no' }
        end

        it 'shows has case concluded as no' do
          expect(page).to have_content('Case concluded? No')
        end
      end
    end

    context 'when pre-order work' do
      let(:application_data) do
        super().deep_merge('case_details' => case_details)
      end

      context 'when pre-order work question was never asked' do
        let(:case_details) do
          { 'is_preorder_work_claimed' => nil }
        end

        it 'hides pre-order work question' do
          expect(page).to have_no_content('Do you intend to claim pre-order work?')
        end
      end

      context 'when not intend to claim pre-order work' do
        let(:case_details) do
          { 'is_preorder_work_claimed' => 'no' }
        end

        it 'shows pre-order work claimed as no' do
          expect(page).to have_content('Do you intend to claim pre-order work? No')
        end
      end

      context 'when intend to claim pre-order work' do
        let(:case_details) do
          {
            'is_preorder_work_claimed' => 'yes',
            'preorder_work_date' => '2021-10-25',
            'preorder_work_details' => 'Lorem ipsum dolor sit amet'
          }
        end

        it 'shows pre-order work claimed as yes' do
          expect(page).to have_content('When you or your firm were first instructed 25/10/2021')
          expect(page).to have_content('Details about the urgency of the work Lorem ipsum dolor sit amet')
        end
      end
    end

    context 'when custody remanded' do
      let(:application_data) do
        super().deep_merge('case_details' => case_details)
      end

      context 'when custody is remanded question was never asked' do
        let(:case_details) do
          { 'is_client_remanded' => nil }
        end

        it 'hides custody is remanded question' do
          expect(page).to have_no_content('Has a court remanded client in custody?')
        end
      end

      context 'when custody is remanded' do
        let(:case_details) do
          { 'is_client_remanded' => 'yes', 'date_client_remanded' => '2021-10-25' }
        end

        it 'shows custody remanded as `In court custody`' do
          expect(page).to have_content('Remanded in court custody? In court custody')
          expect(page).to have_content('When they were remanded 25/10/2021')
        end
      end

      context 'when custody is not remanded' do
        let(:case_details) do
          { 'is_client_remanded' => 'no' }
        end

        it 'shows custody remanded as no' do
          expect(page).to have_content('Remanded in court custody? No')
        end
      end
    end
  end
end
