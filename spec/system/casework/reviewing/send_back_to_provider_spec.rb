require 'rails_helper'

RSpec.describe 'Send an application back to the provider' do
  include_context 'with an existing application'
  include_context 'with a stubbed mailer'

  let(:new_return_path) do
    new_crime_application_return_path(crime_application_id)
  end

  let(:send_back_cta) { 'Send back to provider' }

  context 'when assigned to the application' do
    before do
      click_on 'Kit Pound'
      click_button('Assign to your list')
    end

    it 'the "Send back to provider" button is visible and accessible' do
      expect { click_link(send_back_cta) }.to change { page.current_path }
        .from(crime_application_path(crime_application_id)).to(
          new_return_path
        )
    end

    describe 'adding the return reason' do
      before do
        click_link(send_back_cta)
      end

      it 'shows the applicant name in the heading' do
        expect(page).to have_content "Return Kit Pound's application to provider"
      end

      it 'requires further details' do
        choose 'Duplicate application'
        fill_in 'return-details-details-field', with: ''
        click_button(send_back_cta)

        within '.govuk-error-summary__body' do
          expect(page).to have_content 'Enter a reason for the result'
        end
      end

      it 'requires a reason to be selected' do
        fill_in 'return-details-details-field', with: 'This application was duplicated'
        click_button(send_back_cta)

        within '.govuk-error-summary__body' do
          expect(page).to have_content 'Choose a reason'
        end
      end

      describe 'when successful' do
        before do
          allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
            .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

          choose 'Duplicate application'
          fill_in 'return-details-details-field', with: 'This application was duplicated'
        end

        it 'removes the application from "Your list"' do
          expect(page).to have_content('Your list (1)')

          click_button(send_back_cta)

          expect(page).to have_content('Your list (0)')
        end

        it 'redirects to "Your list" and notifies the caseworker' do
          click_button(send_back_cta)
          expect(page).to have_content 'You sent the application back to the provider'
          expect(page).to have_current_path assigned_applications_path
        end

        it 'calls the NotifyMailer which would send an email to a provider' do
          click_button(send_back_cta)
          expect(NotifyMailer).to have_received(:application_returned_email).with(
            crime_application_id, 'duplicate_application'
          )
          expect(mailer_double).to have_received(:deliver_later)
        end
      end

      context 'when there is a conflict with the datastore' do
        before do
          allow(Rails.error).to receive(:report)

          stub_request(
            :put, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}/return"
          ).and_return(body: { error: 'oops' }.to_json, status: 409)

          choose 'Duplicate application'
          fill_in 'return-details-details-field', with: 'This application was duplicated'
          click_button(send_back_cta)
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
    end

    describe 'viewing the returned application' do
      before do
        allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
          .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

        click_link(send_back_cta)

        choose 'Duplicate application'
        fill_in 'return-details-details-field', with: 'This application was duplicated'
        click_button(send_back_cta)

        visit(crime_application_path(crime_application_id))
      end

      it 'includes the page title' do
        expect(page).to have_content I18n.t('casework.crime_applications.show.page_title')
      end

      it 'shows the sent back status tag' do
        tag = page.all('.govuk-tag.govuk-tag--red').first.text

        expect(tag).to match('Sent back to provider')
      end

      it 'includes the applicant details' do
        expect(page).to have_content('AJ123456C')
      end

      it 'does not show the CTAs' do
        expect(page).to have_no_content('Mark as completed')
      end
    end
  end

  context 'when not assigned to the application' do
    let(:assignee_id) do
      User.create(first_name: 'A', last_name: 'Caseworder').id
    end

    before do
      click_on 'Open applications'
      click_on('Kit Pound')
    end

    it 'the "Send back to provider" button is not visible' do
      expect(page).to have_no_button(send_back_cta)
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

      click_link(send_back_cta)
      choose 'Need clarification'
      fill_in 'Give details', with: 'Details needed'
      click_button 'Send back to provider'
    end

    it 'cannot be sent back' do
      expect(page).to have_notification_banner(text: 'You cannot review this application',
                                               details: ['It has been reassigned to another team member.',
                                                         'Contact your supervisor if you need to work on ' \
                                                         'this application.'],
                                               success: false)
    end
  end

  context 'with errors Reviewing::' do
    before do
      visit new_return_path
      command_double = instance_double(Reviewing::SendBack)

      allow(command_double).to receive(:call) { raise error_class }

      allow(Reviewing::SendBack).to receive(:new) { command_double }

      choose 'Duplicate application'
      fill_in 'return-details-details-field', with: 'This application was duplicated'

      click_button(send_back_cta)
    end

    describe 'AlreadyReviewed' do
      let(:error_class) { Reviewing::AlreadyReviewed }
      let(:message) { 'This application was already reviewed' }

      it 'notifies that the application was already reviewed' do
        expect(page).to have_notification_banner text: message
      end

      it 'does not send the notification email' do
        expect(NotifyMailer).not_to have_received(:application_returned_email)
      end
    end
  end
end
