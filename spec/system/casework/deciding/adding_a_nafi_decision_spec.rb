require 'rails_helper'

RSpec.describe 'Adding a NAFI decision' do
  include AsssignmentHelpers

  include_context 'with stubbed application'
  include_context 'when adding a decision by MAAT ID'

  before do
    allow(mock_get_decision).to receive(:by_usn!).and_raise(Maat::RecordNotFound)
    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
    click_button 'Add funding decision from MAAT'
    fill_in('MAAT ID', with: maat_id)
  end

  let(:maat_id) { 123 }
  let(:maat_decision_maat_id) { maat_id }
  let(:maat_decision_ioj_reason) { 'Note that NAFI received' }

  let(:original_application) do
    instance_double(
      CrimeApplication,
      reference: maat_decision_reference,
      id: SecureRandom.uuid,
      application_type: 'initial',
      initial?: true
    )
  end

  context 'when found MAAT application has a different USN' do
    before { save_and_continue }

    let(:maat_decision_reference) { 6_000_002 }

    context 'when the MAAT decision is not marked as NAFI' do
      let(:maat_decision_ioj_reason) { 'Normal IoJ Decision' }

      it 'shows an error' do
        expect(page).to have_error(
          'MAAT ID', 'This MAAT ID is linked to another LAA reference number'
        )
      end
    end

    it 'links the MAAT ID' do
      expect(page).to have_success_notification_banner(
        text: 'MAAT ID 123 linked'
      )

      expect(current_path).to eq(
        "/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/decisions/#{maat_id}/comment"
      )
    end
  end

  context 'when the MAAT ID is linked to a different draft application on review' do
    let(:user_id) { SecureRandom.uuid }
    let(:application_id) { original_application.id }

    before do
      with_assignment(user_id: user_id, assignment_id: application_id) do
        Maat::LinkDecision.call(
          application: original_application,
          maat_id: maat_id, user_id: user_id
        )
      end

      save_and_continue
    end

    it 'shows an error when the original application is not sent' do
      expect(page).to have_error(
        'MAAT ID', 'This MAAT ID is linked to another application'
      )
    end
  end

  context 'when the MAAT ID is linked to a different sent application on review' do
    let(:user_id) { SecureRandom.uuid }
    let(:application_id) { original_application.id }

    before do
      with_assignment(user_id: user_id, assignment_id: application_id) do
        Maat::LinkDecision.call(
          application: original_application,
          maat_id: maat_id, user_id: user_id
        )
        Reviewing::Complete.call(
          application_id:, user_id:
        )
      end

      save_and_continue
    end

    it 'links to the MAAT ID' do
      expect(page).to have_success_notification_banner(text: "MAAT ID #{maat_id} linked")

      expect(current_path).to eq(
        "/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/decisions/#{maat_id}/comment"
      )
    end

    it 'the NAFI decision can be removed' do
      click_button('Remove')

      expect(page).to have_success_notification_banner(
        text: 'Decision removed'
      )
    end

    context 'when the MAAT decision is not marked as NAFI' do
      let(:maat_decision_ioj_reason) { 'Normal IoJ Decision' }

      it 'shows an error' do
        expect(page).to have_error(
          'MAAT ID', 'This MAAT ID is linked to another application'
        )
      end
    end
  end
end
