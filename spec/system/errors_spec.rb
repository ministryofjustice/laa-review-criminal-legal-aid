require 'rails_helper'

RSpec.describe 'Error pages' do
  context 'when authenticated' do
    context 'when crime application is not found' do
      before do
        visit '/applications/123'
      end

      it 'shows the application not found error page' do
        expect(page).to have_content "If you're looking for a specific application, go to open applications."
        expect(page).to have_http_status(:not_found)
      end

      it 'uses the system user layout with navigation' do
        expect(page).to have_css('nav.govuk-service-navigation__wrapper')
        expect(page).to have_link('Sign out')
      end
    end

    context 'when the datastore returns an unhandled error' do
      before do
        stub_request(
          :post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches"
        ).and_return(body: { error: 'oops' }.to_json, status: 500)

        allow(Rails.error).to receive(:report)

        visit '/'
      end

      context 'when a search is made' do
        before do
          click_on 'Search'
          click_button 'Search'
        end

        it 'reports the exception' do
          expect(Rails.error).to have_received(:report)
        end

        it 'shows an error message' do
          within('.govuk-main-wrapper') do
            expect(page).to have_content([
              'Sorry, there is a problem with the service',
              'Try again later.',
              'If this problem continues, contact LAAapplyonboarding@justice.gov.uk for help'
            ].join("\n"))
          end
        end

        it 'returns a 500 error status' do
          expect(page).to have_http_status :internal_server_error
        end

        it 'uses the system user layout with navigation' do
          expect(page).to have_css('nav.govuk-service-navigation__wrapper')
          expect(page).to have_link('Sign out')
        end
      end
    end

    context 'when viewing a crime application with a datastore error' do
      before do
        allow(Rails.error).to receive(:report)

        stub_request(
          :get,
          "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
        ).to_return(body: { error: 'ooops' }.to_json, status: 401)

        visit crime_application_path(id: application_id)
      end

      let(:application_id) { SecureRandom.uuid }

      it 'reports the exception' do
        expect(Rails.error).to have_received(:report) # .with(error, hash_including(handled: true, severity: :error))
      end

      it 'shows an error message' do
        within('.govuk-main-wrapper') do
          expect(page).to have_content([
            'Sorry, there is a problem with the service',
            'Try again later.',
            'If this problem continues, contact LAAapplyonboarding@justice.gov.uk for help'
          ].join("\n"))
        end
      end

      it 'returns a 500 error status' do
        expect(page).to have_http_status :internal_server_error
      end

      it 'uses the system user layout with navigation' do
        expect(page).to have_css('nav.govuk-service-navigation__wrapper')
        expect(page).to have_link('Sign out')
      end
    end

    context 'when there is a conflict between the datastore and Crime Review data' do
      include_context 'with an existing application'

      before do
        allow(Rails.error).to receive(:report)

        stub_request(
          :put, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}/mark_as_ready"
        ).and_return(body: { error: 'oops' }.to_json, status: 409)

        click_on 'Kit Pound'
        click_button('Assign to your list')
        click_button('Mark as ready for MAAT')
      end

      it 'reports the exception' do
        expect(Rails.error).to have_received(:report) # .with(error, hash_including(handled: true, severity: :error))
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

    context 'when visiting a non existent page' do
      before do
        visit '/not/a/page'
      end

      it 'shows not found error page' do
        expect(page).to have_content 'If the web address is correct or you selected a link or button'
        expect(page).to have_http_status(:not_found)
      end

      it 'uses the simplified errors page layout' do
        expect(page).to have_no_css('nav.govuk-service-navigation__wrapper')
      end
    end

    context 'when visiting a forbidden page' do
      before do
        visit users_auth_failure_path
      end

      it 'shows the forbidden page' do
        expect(page).to have_content 'Access to this service is restricted'
        expect(page).to have_http_status(:forbidden)
      end

      it 'uses the simplified errors page layout' do
        expect(page).to have_no_css('nav.govuk-service-navigation__wrapper')
      end
    end

    context 'when visiting an admin page to manage a user' do
      include_context 'with an existing user'

      it 'shows forbidden even if the user exists' do
        visit "/manage-users/history/#{user.id}"
        expect(page).to have_http_status :forbidden
        visit '/manage-users/history/n0tan1d'
        expect(page).to have_http_status :forbidden
      end

      it 'uses the errors layout' do
        visit "/manage-users/history/#{user.id}"
        expect(page).to have_no_css '#navigation'
        expect(page).to have_no_content 'Sign out'
      end
    end
  end

  context 'when not authenticated' do
    include_context 'when not logged in'

    context 'when visiting a non existent page not on a service path' do
      it 'shows "Page not found"' do
        visit '/._darcs'
        expect(page).to have_content 'Page not found'
        expect(page).to have_http_status :not_found
      end
    end

    context 'when visiting a non existent page' do
      include_context 'with an existing application'

      it 'redirects to sign in even if application does not exist' do
        expected_content = 'Sign in to access the service'
        visit "/applications/#{crime_application_id}"
        expect(page).to have_content expected_content
        visit '/applications/n0tan1d'
        expect(page).to have_content expected_content
      end
    end

    context 'when visiting a link to manage a user' do
      include_context 'with an existing user'

      it 'redirects to sign in even if the user exists' do
        expected_content = 'Sign in to access the service'
        visit "/manage-users/history/#{user.id}"
        expect(page).to have_content expected_content
        visit '/manage-users/history/n0tan1d'
        expect(page).to have_content expected_content
      end
    end

    describe 'requesting a missing asset' do
      it 'returns 404 header only' do
        visit '/assets/application-087fa64db5215e96ca2275687c1c7ffa01124ae348224715f68c0d2c0d3da4a0.css'
        expect(page.text).to eq 'Not found'
        expect(page).to have_http_status(:not_found)
      end
    end
  end

  context 'when logged in as user that can manage others' do
    include_context 'when logged in user is admin'

    context 'when visiting a link to an application' do
      include_context 'with an existing application'

      it 'denies access' do
        visit "/applications/#{crime_application_id}"
        expect_forbidden

        visit '/applications/n0tan1d'
        expect_forbidden
      end
    end

    context 'when visiting a link to manage a non existent user' do
      it 'show page not found' do
        visit '/manage-users/history/n0tan1d'
        expect(page).to have_content 'Page not found'
        expect(page).to have_http_status(:not_found)
      end
    end
  end
end
