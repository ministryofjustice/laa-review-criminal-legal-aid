require 'rails_helper'

RSpec.describe 'When viewing an case details' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with case details' do
    context 'when case type is not an appeal type' do
      let(:application_data) do
        super().deep_merge('case_details' => { 'case_type' => 'either_way' })
      end

      it 'does not show appeal lodged date section' do
        expect(page).not_to have_content('Appeal lodged')
      end

      it 'does not show change details section' do
        expect(page).not_to have_content('Change of financial circumstances details')
      end

      it 'does not show previous maat id section' do
        expect(page).not_to have_content('Previous MAAT ID')
      end
    end

    context 'when case type is an appeal' do
      context 'when previous MAAT ID is not provided' do
        it 'shows appeal lodged date' do
          expect(page).to have_content('Date the appeal was lodged 25/10/2021')
          expect(page).to have_content('Previous MAAT ID Not provided')
        end
      end

      context 'when previous MAAT ID is provided' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'appeal_maat_id' => '123456' })
        end

        it 'shows previous maat id' do
          expect(page).to have_content('Previous MAAT ID 123456')
        end
      end
    end

    context 'when case type is an appeal with changes to financial circumstances' do
      let(:application_data) do
        super().deep_merge('case_details' => { 'case_type' => 'appeal_to_crown_court_with_changes',
                                               'appeal_with_changes_details' => 'Some details' })
      end

      it 'shows appeal lodged date' do
        expect(page).to have_content('Date the appeal was lodged 25/10/2021')
      end

      it 'shows changes to details' do
        expect(page).to have_content('Changes in the client’s financial circumstances Some details')
      end

      it 'does not show previous maat id section' do
        expect(page).not_to have_content('Previous MAAT ID')
      end
    end

    context 'when case concluded' do
      context 'when case is concluded' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'has_case_concluded' => 'yes',
                                                 'date_case_concluded' => '2021-10-25' })
        end

        it 'shows has case concluded as yes' do
          expect(page).to have_content('Has the case concluded? Yes')
          expect(page).to have_content('When the case concluded 25/10/2021')
        end
      end

      context 'when case is not concluded' do
        it 'shows has case concluded as no' do
          expect(page).to have_content('Has the case concluded? No')
        end
      end
    end

    context 'when pre-order work' do
      let(:application_data) do
        super().deep_merge('case_details' => { 'is_preorder_work_claimed' => 'no' })
      end

      context 'when not intend to claim pre-order work' do
        it 'shows pre-order work claimed as no' do
          expect(page).to have_content('Do you intend to claim pre-order work? No')
        end
      end

      context 'when intend to claim pre-order work' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'is_preorder_work_claimed' => 'yes',
                                                 'preorder_work_date' => '2021-10-25',
                                                 'preorder_work_details' => 'Lorem ipsum dolor sit amet' })
        end

        it 'shows pre-order work claimed as yes' do
          expect(page).to have_content('When you or your firm were first instructed 25/10/2021')
          expect(page).to have_content('Details about the urgency of the work Lorem ipsum dolor sit amet')
        end
      end
    end

    context 'when custody remanded' do
      context 'when custody is remanded' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'is_client_remanded' => 'yes',
                                                 'date_client_remanded' => '2021-10-25' })
        end

        it 'shows custody remanded as yes' do
          expect(page).to have_content('Has a court remanded client in custody? Yes')
          expect(page).to have_content('When they were remanded 25/10/2021')
        end
      end

      context 'when custody is not remanded' do
        it 'shows custody remanded as no' do
          expect(page).to have_content('Has a court remanded client in custody? No')
        end
      end
    end
  end
end
