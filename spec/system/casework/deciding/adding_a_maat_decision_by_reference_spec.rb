require 'rails_helper'

RSpec.describe 'Adding a decision by MAAT reference' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  let(:mock_get_decision) { instance_double(Maat::GetDecision) }
  let(:reference) { 6_000_001 }
  let(:maat_decision) { nil }

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

    if maat_decision.present?
      allow(mock_get_decision).to receive(:by_usn!).with(reference).and_return(maat_decision)
    else
      allow(mock_get_decision).to receive(:by_usn!).with(reference).and_raise(Maat::RecordNotFound)
    end

    allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
  end

  it 'informs that the application must be added to MAAT' do
    expect(page).to have_selector 'h2', text: 'Funding decision'
    expect(page).to have_selector(
      'p',
      text: 'To add one or more funding decisions, link the application in MAAT first.'
    )
  end

  context 'when an application for the reference is not found on MAAT' do
    it 'informs the caseworker and redirects them to add by MAAT ID' do
      click_button 'Add funding decision from MAAT'

      expect(page).to have_notification_banner(
        text: 'No MAAT ID found that links to LAA reference number 6000001'
      )
      expect(current_path).to eq('/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/link-maat-id')
    end
  end

  context 'when an application for the reference is found on MAAT' do
    let(:maat_decision) do
      Maat::Decision.new(
        maat_ref: 999_333,
        usn: 6_000_001,
        ioj_result: 'PASS',
        ioj_assessor_name: 'Jo Bloggs',
        app_created_date: 1.day.ago.to_s,
        means_result: 'PASS',
        means_assessor_name: 'Jo Bloggs',
        date_means_created:  1.day.ago.to_s,
        funding_decision: 'GRANTED'
      )
    end

    it 'informs the caseworker and redirects them add by MAAT ID' do
      click_button 'Add funding decision from MAAT'

      expect(page).to have_success_notification_banner(
        text: 'MAAT ID 999333 linked'
      )

      expect(current_path).to eq(
        '/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/decisions/999333/comment'
      )
    end
  end

  context 'when the application is reassigned while the page is already loaded' do
    before do
      another_user = User.create!(
        email: 'Bob.EXAMPLE@justice.gov.uk',
        first_name: 'Bob',
        last_name: 'EXAMPLE',
        auth_subject_id: SecureRandom.uuid,
        first_auth_at: 1.month.ago,
        last_auth_at: 1.hour.ago,
        can_manage_others: false,
        role: UserRole::CASEWORKER
      )

      # another user reassigns the application to themselves
      Assigning::ReassignToUser.new(assignment_id: application_id, user_id: another_user.id,
                                    to_whom_id: another_user.id, from_whom_id: current_user_id).call

      click_button 'Add funding decision from MAAT'
    end

    it 'does not allow to add a decision' do
      expect(page).to have_notification_banner(text: 'This application is assigned to someone else',
                                               details: 'Ask your supervisor if you need to work on it.',
                                               success: false)
    end
  end
end
