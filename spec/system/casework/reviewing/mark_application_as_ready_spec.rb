require 'rails_helper'

RSpec.describe 'Marking an application as ready for assessment' do
  include_context 'with an existing application'

  let(:ready_for_assessment_cta) { 'Mark as ready for MAAT' }

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

    it 'has a visable "Mark as ready for MAAT" CTA' do
      expect(page).to have_content('Mark as ready for MAAT')
    end

    it 'redirects to the correct page' do
      expect { click_button(ready_for_assessment_cta) }.not_to(change { page.current_path })
    end

    it 'shows success flash message' do
      click_button(ready_for_assessment_cta)
      expect(page).to have_content('Application ready for assessment in MAAT.')
    end

    context 'with errors Reviewing::' do
      before do
        click_on 'Open applications'
        click_on('Kit Pound')
        command_double = instance_double(Reviewing::MarkAsReady)

        allow(command_double).to receive(:call) { raise error_class }

        allow(Reviewing::MarkAsReady).to receive(:new) { command_double }

        click_button(ready_for_assessment_cta)
      end

      describe 'AlreadyMarkedAsReady' do
        let(:error_class) { Reviewing::AlreadyMarkedAsReady }
        let(:message) do
          'This application was already marked as ready for assessment'
        end

        it 'notifies that the application has already been marked as ready for assessment' do
          expect(page).to have_notification_banner text: message
        end
      end

      describe 'CannotMarkAsReadyWhenCompleted' do
        let(:error_class) { Reviewing::AlreadyReviewed }
        let(:message) { 'This application was already reviewed' }

        it 'notifies that the application has already been completed' do
          expect(page).to have_notification_banner text: message
        end
      end
    end
  end

  context 'when not assigned to the application' do
    before do
      click_on 'Open applications'
      click_on('Kit Pound')
    end

    it 'the "Ready for assessment" button is not visable' do
      expect(page).to have_no_button(ready_for_assessment_cta)
    end
  end
end
