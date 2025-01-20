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

    context 'when a datastore api error exists' do
      include_context 'with stubbed assignments and reviews'

      before do
        stub_request(:post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches")
          .to_raise error

        visit '/'
      end

      ['Review next application', 'Open applications', 'Closed applications'].each do |step|
        let(:error) { DatastoreApi::Errors::Unauthorized.new }

        context "when '#{step}' is clicked on" do
          before do
            allow(Rails.error).to receive(:report)
            click_on step
          end

          it 'reports the exception' do
            expect(Rails.error).to have_received(:report).with(error, hash_including(handled: true, severity: :error))
          end

          it 'shows an error message' do
            expect(page).to have_content 'Sorry, something went wrong with our service'
            expect(page).to have_content 'We cannot connect to our database'
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
    end

    context 'when viewing a crime application with a datastore error' do
      before do
        allow(Rails.error).to receive(:report)

        stub_request(:get,
                     "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}").to_raise(error)

        visit crime_application_path(id: application_id)
      end

      let(:error) { DatastoreApi::Errors::ConnectionError.new }
      let(:application_id) { SecureRandom.uuid }

      it 'reports the exception' do
        expect(Rails.error).to have_received(:report).with(error, hash_including(handled: true, severity: :error))
      end

      it 'shows an error message' do
        expect(page).to have_content 'Sorry, something went wrong with our service'
        expect(page).to have_content 'We cannot connect to our database'
      end

      it 'returns a 500 error status' do
        expect(page).to have_http_status :internal_server_error
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
      it 'returns the service page not found page' do
        visit '/assets/application-087fa64db5215e96ca2275687c1c7ffa01124ae348224715f68c0d2c0d3da4a0.css'
        expect(page).to have_content 'Page not found'
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
