require 'rails_helper'

RSpec.describe 'Adding a decision by MAAT ID' do
  include_context 'with stubbed application'
  include_context 'when adding a decision by MAAT ID'

  let(:application_id) { '98ab235c-f125-4dcb-9604-19e81782e53b' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'change_in_financial_circumstances').read) }

  let(:original_application) do
    instance_double(
      CrimeApplication,
      reference: 100_000_123,
      id: SecureRandom.uuid,
      application_type: 'initial',
      cifc?: true
    )
  end

  before do
    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    find('p', text: 'To add the funding decision, update the original application in MAAT first.')
    click_button 'Add funding decision from MAAT'
    fill_in('MAAT ID', with: maat_id)
  end

  context 'when the original maat record is found' do
    let(:maat_id) { 987_654_321 }

    let(:maat_decision_maat_id) { maat_id }
    let(:maat_decision_reference) { original_application.reference }

    it 'creates the decision and shows the success message' do
      save_and_continue
      expect(page).to have_success_notification_banner(
        text: "MAAT ID #{maat_id} linked"
      )

      expect(current_path).to eq(
        "/applications/98ab235c-f125-4dcb-9604-19e81782e53b/decisions/#{maat_id}/comment"
      )
    end

    context 'when the MAAT ID is linked on review' do
      before do
        Maat::CreateDraftDecisionFromMaatId.call(
          application: original_application,
          maat_id: maat_id, user_id: SecureRandom.uuid
        )
      end

      it 'shows an error when the original application is not sent' do
        save_and_continue
        expect(page).to have_error(
          'MAAT ID', 'This MAAT ID is linked to another application'
        )
      end

      it 'links the CIFC to the draft decision' do
        Reviewing::Complete.call(
          application_id: original_application.id, user_id: SecureRandom.uuid
        )

        save_and_continue

        expect(page).to have_success_notification_banner(text: "MAAT ID #{maat_id} linked")

        expect(current_path).to eq(
          "/applications/98ab235c-f125-4dcb-9604-19e81782e53b/decisions/#{maat_id}/comment"
        )
      end

      it 'the CIFC decision can be removed' do
        Reviewing::Complete.call(
          application_id: original_application.id, user_id: SecureRandom.uuid
        )

        save_and_continue
        click_button('Remove')

        expect(page).to have_success_notification_banner(
          text: 'Decision removed'
        )
      end
    end
  end
end
