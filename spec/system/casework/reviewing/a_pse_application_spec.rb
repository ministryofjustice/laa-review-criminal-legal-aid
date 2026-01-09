require 'rails_helper'

RSpec.describe 'Reviewing a PSE application' do
  include_context 'with stubbed application'

  let(:application_id) { '21c37e3e-520f-46f1-bd1f-5c25ffc57d70' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence').read) }
  let(:complete_cta) { 'Mark as completed' }

  context 'when assigned to the application' do
    before do
      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).and_return(
        instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
      )

      visit crime_application_path(application_id)
      click_button 'Assign to your list'
    end

    it 'can be completed by the caseworker' do
      expect(page).not_to have_button('Send back to provider')
      click_button 'Mark as completed'
      expect(page).to have_content('You marked the application as complete')
    end

    it 'removes the application from "Your list"' do
      expect(page).to have_content('Your list (1)')
      click_button 'Mark as completed'
      expect(page).to have_content('Your list (0)')
    end

    context 'with errors Reviewing::' do
      before do
        command_double = instance_double(Reviewing::Complete)

        allow(command_double).to receive(:call) { raise error_class }

        allow(Reviewing::Complete).to receive(:new) { command_double }

        click_button(complete_cta)
      end

      describe 'AlreadyCompleted' do
        let(:error_class) { Reviewing::AlreadyReviewed }
        let(:message) do
          'This application was already reviewed'
        end

        it 'notifies that the application has already been completed' do
          expect(page).to have_notification_banner text: message
        end
      end

      describe 'IncompleteDecisions' do
        let(:error_class) { Reviewing::IncompleteDecisions }
        let(:message) { 'Please complete any pending funding decisions' }

        it 'notifies that the application has already been sent back' do
          expect(page).to have_notification_banner text: message
        end
      end
    end
  end

  context 'when not assigned to the application' do
    before do
      visit crime_application_path(application_id)
    end

    it 'the "Mark as completed" button is not visible' do
      expect(page).to have_no_button(complete_cta)
    end
  end

  context 'when reassigned while the page is already loaded' do
    before do
      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
        .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

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

      # current user assigns the application to themselves
      visit crime_application_path(application_id)
      click_button('Assign to your list')

      # another user reassigns the application to themselves
      Assigning::ReassignToUser.new(assignment_id: application_id, user_id: another_user.id,
                                    to_whom_id: another_user.id, from_whom_id: current_user_id).call

      click_button(complete_cta)
    end

    it 'cannot be marked as completed' do
      expect(page).to have_notification_banner(text: 'You cannot review this application',
                                               details: ['It has been reassigned to another team member.',
                                                         'Contact your supervisor if you need to work on ' \
                                                         'this application.'],
                                               success: false)
    end
  end
end
