require 'rails_helper'

RSpec.describe 'Marking an application as ready for assessment' do
  include_context 'with an existing application'

  let(:ready_for_assessment_cta) { 'Mark as ready' }

  before do
    visit '/'
  end

  context 'when assigned to the application' do
    let(:assignee_id) { current_user_id }

    before do
      Assigning::AssignToUser.new(
        assignment_id: crime_application_id,
        user_id: assignee_id,
        to_whom_id: assignee_id
      ).call

      click_on 'Your list'
      click_on 'Kit Pound'
    end

    it 'has a visable "Mark as ready" CTA' do
      expect(page).to have_content('Mark as ready')
    end

    it 'redirects to the correct page' do
      expect { click_button(ready_for_assessment_cta) }.to change { page.current_path }
        .from(crime_application_path(crime_application_id)).to(
          assigned_applications_path
        )
    end

    it 'shows success flash message' do
      click_button(ready_for_assessment_cta)
      expect(page).to have_content('The application has been marked as ready for assessment')
    end

    context 'with errors Reviewing::' do
      before do
        click_on 'All open applications'
        click_on('Kit Pound')
        command_double = instance_double(Reviewing::MarkAsReady)

        allow(command_double).to receive(:call) { raise error_class }

        allow(Reviewing::MarkAsReady).to receive(:new) { command_double }

        click_button(ready_for_assessment_cta)
      end

      describe 'AlreadyMarkedAsReady' do
        let(:error_class) { Reviewing::AlreadyMarkedAsReady }
        let(:message) do
          'The application has already been marked as ready for assessment'
        end

        it 'notifies that the application has already been marked as ready for assessment' do
          expect(page).to have_content message
        end
      end

      describe 'CannotMarkAsReadyWhenSentBack' do
        let(:error_class) { Reviewing::CannotMarkAsReadyWhenSentBack }
        let(:message) { 'This application has already been sent back to the provider' }

        it 'notifies that the application has already been sent back' do
          expect(page).to have_content message
        end
      end

      describe 'CannotMarkAsReadyWhenCompleted' do
        let(:error_class) { Reviewing::CannotMarkAsReadyWhenCompleted }
        let(:message) { 'This application has already been marked as complete' }

        it 'notifies that the application has already been complete' do
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

    it 'the "Ready for assessment" button is not visable' do
      expect(page).not_to have_button(ready_for_assessment_cta)
    end
  end
end