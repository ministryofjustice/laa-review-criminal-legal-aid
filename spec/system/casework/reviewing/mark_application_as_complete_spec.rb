require 'rails_helper'

RSpec.describe 'Marking an application as complete' do
  include_context 'with an existing application'

  let(:complete_cta) { 'Mark as completed' }

  before do
    visit '/'
    click_on 'Open applications'
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

      Reviewing::MarkAsReady.new(
        user_id: assignee_id,
        application_id: crime_application_id
      ).call

      click_on 'Your list'
      click_on 'Kit Pound'
    end

    it 'has a visable "Mark as completed" CTA' do
      expect(page).to have_content('Mark as completed')
    end

    it 'redirects to the correct page' do
      expect { click_button(complete_cta) }.to change { page.current_path }
        .from(crime_application_path(crime_application_id)).to(
          crime_application_complete_path(crime_application_id)
        )
    end

    it 'shows success flash message' do
      click_button(complete_cta)
      expect(page).to have_content('You marked the application as complete')
    end

    it 'removes the application from "Your list"' do
      expect(page).to have_content('Your list (1)')

      click_button(complete_cta)

      expect(page).to have_content('Your list (0)')
    end

    context 'with errors Reviewing::' do
      before do
        click_on 'Open applications'
        click_on('Kit Pound')
        command_double = instance_double(Reviewing::Complete)

        allow(command_double).to receive(:call) { raise error_class }

        allow(Reviewing::Complete).to receive(:new) { command_double }

        click_button(complete_cta)
      end

      describe 'AlreadyCompleted' do
        let(:error_class) { Reviewing::AlreadyCompleted }
        let(:message) do
          'This application was already marked as complete'
        end

        it 'notifies that the application has already been completed' do
          expect(page).to have_content message
        end
      end

      describe 'CannotCompleteWhenSentBack' do
        let(:error_class) { Reviewing::CannotCompleteWhenSentBack }
        let(:message) { 'This application was already sent back to the provider' }

        it 'notifies that the application has already been sent back' do
          expect(page).to have_content message
        end
      end
    end
  end

  context 'when not assigned to the application' do
    before do
      click_on 'Open applications'
      click_on('Kit Pound')
    end

    it 'the "Mark as completed" button is not visable' do
      expect(page).to have_no_button(complete_cta)
    end
  end
end
