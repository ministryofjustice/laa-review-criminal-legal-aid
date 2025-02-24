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

    it 'the "Mark as completed" button is not visable' do
      expect(page).to have_no_button(complete_cta)
    end
  end
end
