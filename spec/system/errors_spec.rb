require 'rails_helper'

RSpec.describe 'Error pages' do
  context 'when authenticated' do
    context 'when an unhandled error occurs' do
      before do
        allow(ApplicationSearchFilter).to receive(:new) {
          raise StandardError
        }

        visit '/'
        click_on 'Search'
      end

      it 'shows the unhandled error page and status' do
        expect(page).to have_content 'Sorry, something went wrong with our service'
        expect(page).to have_http_status(:internal_server_error)
      end

      it 'uses the simplified error page layout' do
        expect(page).not_to have_css('nav.moj-primary-navigation')
      end
    end

    context 'when crime application is not found' do
      before do
        visit '/applications/123'
      end

      it 'shows the application not found error page' do
        expect(page).to have_content "If you're looking for a specific application, go to all open applications."
        expect(page).to have_http_status(:not_found)
      end

      it 'uses the system user layout with navigation' do
        expect(page).to have_css('nav.moj-primary-navigation')
      end
    end

    context 'when crime application is found' do
      include_context 'with an existing application'

      before do
        visit "/applications/#{crime_application_id}"
      end

      it 'shows the application' do
        expect(page).to have_content 'AJ 12 34 56'
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
        expect(page).not_to have_css('nav.moj-primary-navigation')
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
        expect(page).not_to have_css('nav.moj-primary-navigation')
      end
    end

    context 'when visiting an admin page to manage a user' do
      include_context 'with an existing user'

      it 'shows "Page not found" even if the user exists' do
        expected_content = 'Page not found'
        visit "/admin/manage_users/history/#{user.id}"
        expect(page).to have_content expected_content
        visit '/admin/manage_users/history/n0tan1d'
        expect(page).to have_content expected_content
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
        visit "/admin/manage_users/history/#{user.id}"
        expect(page).to have_content expected_content
        visit '/admin/manage_users/history/n0tan1d'
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

  context 'when logged in admin' do
    include_context 'when logged in user is admin'

    context 'when visiting a link to an application' do
      include_context 'with an existing application'

      it 'shows a standard 404 even if application exists' do
        visit "/applications/#{crime_application_id}"
        expect(page).to have_content 'Page not found'
        visit '/applications/n0tan1d'
        expect(page).to have_content 'Page not found'
      end
    end

    context 'when visiting a link to manage a non existent user' do
      it 'show page not found' do
        visit '/admin/manage_users/history/n0tan1d'
        expect(page).to have_content 'Page not found'
        expect(page).to have_http_status(:not_found)
      end
    end
  end
end
