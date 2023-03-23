require 'rails_helper'

RSpec.describe 'Marking an application as complete' do
  include_context 'with an existing application'

  let(:complete_cta) { 'Mark as complete' }

  before do
    visit '/'
  end

  context 'when assigned to the application' do
    let(:assignee_id) { current_user_id }

    before do
      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
        .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

      Assigning::AssignToUser.new(
        assignment_id: crime_application_id,
        user_id: assignee_id,
        to_whom_id: assignee_id
      ).call

      click_on 'Your list'
      click_on 'Kit Pound'
    end

    it 'has a visable "Mark as complete" CTA' do
      expect(page).to have_content('Mark as complete')
    end

    it 'redirects to the correct page' do
      expect { click_button(complete_cta) }.to change { page.current_path }
        .from(crime_application_path(crime_application_id)).to(
          assigned_applications_path
        )
    end

    it 'shows success flash message' do
      click_button(complete_cta)
      expect(page).to have_content('The application has been marked as complete')
    end

    it 'removes the application from "Your list"' do
      expect(page).to have_content('Your list (1)')

      click_button(complete_cta)

      expect(page).to have_content('Your list (0)')
    end

    context 'with errors Reviewing::' do
      before do
        click_on 'All open applications'
        click_on('Kit Pound')
        command_double = instance_double(Reviewing::Complete)

        allow(command_double).to receive(:call) { raise error_class }

        allow(Reviewing::Complete).to receive(:new) { command_double }

        click_button(complete_cta)
      end

      describe 'AlreadyCompleted' do
        let(:error_class) { Reviewing::AlreadyCompleted }
        let(:message) do
          'This application has already been marked as complete'
        end

        it 'notifies that the application has already been completed' do
          expect(page).to have_content message
        end
      end

      describe 'CannotCompleteWhenSentBack' do
        let(:error_class) { Reviewing::CannotCompleteWhenSentBack }
        let(:message) { 'This application has already been sent back to the provider' }

        it 'notifies that the application has already been sent back' do
          expect(page).to have_content message
        end
      end
    end
  end

  context 'when not assigned to the application' do
    before do
      click_on 'All open applications'
      click_on('Kit Pound')
    end

    it 'the "Mark as complete" button is not visable' do
      expect(page).not_to have_button(complete_cta)
    end
  end
end
