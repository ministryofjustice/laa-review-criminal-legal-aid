require 'rails_helper'

RSpec.describe 'Marking an application as ready for assessment' do
  include_context 'with an existing application'

  let(:ready_for_assessment_cta) { 'Mark as ready for MAAT' }

  context 'when assigned to the application' do
    before do
      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
        .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

      click_on 'Kit Pound'
      click_button('Assign to your list')
    end

    it 'has a visible "Mark as ready for MAAT" CTA' do
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

  context 'when marked as ready in the datastore but not on Review' do
    before do
      click_on 'Kit Pound'
      click_button('Assign to your list')

      allow(Rails.error).to receive(:report)

      stub_request(
        :put, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}/mark_as_ready"
      ).and_return(body: { error: 'oops' }.to_json, status: 409)

      click_button(ready_for_assessment_cta)
    end

    it 'reports the exception' do
      expect(Rails.error).to have_received(:report)
    end

    it 'shows an error message' do
      within('.govuk-main-wrapper') do
        expect(page).to have_content([
          'Sorry, there is a problem with your request',
          'You can go back, refresh the page, and try again.',
          'If this problem continues, contact LAAapplyonboarding@justice.gov.uk for help'
        ].join("\n"))
      end
    end

    it 'returns a 409 error status' do
      expect(page).to have_http_status :unprocessable_entity
    end

    it 'uses the system user layout with navigation' do
      expect(page).to have_css('nav.govuk-service-navigation__wrapper')
      expect(page).to have_link('Sign out')
    end
  end

  context 'when not assigned to the application' do
    before do
      click_on 'Open applications'
      click_on('Kit Pound')
    end

    it 'the "Ready for assessment" button is not visible' do
      expect(page).to have_no_button(ready_for_assessment_cta)
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
      click_on('Kit Pound')
      click_button('Assign to your list')

      # another user reassigns the application to themselves
      Assigning::ReassignToUser.new(assignment_id: crime_application_id, user_id: another_user.id,
                                    to_whom_id: another_user.id, from_whom_id: current_user_id).call

      click_button(ready_for_assessment_cta)
    end

    it 'cannot be marked as ready' do
      expect(page).to have_notification_banner(text: 'Action could not be completed',
                                               details: 'This application is assigned to another user.', success: false)
    end
  end
end
