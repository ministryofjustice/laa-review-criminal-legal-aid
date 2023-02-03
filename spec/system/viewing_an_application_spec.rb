require 'rails_helper'

RSpec.describe 'Viewing an application' do
  include_context 'with stubbed search'

  let(:assign_cta) { 'Assign to myself' }
  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  context 'when an application exists in the datastore' do
    context 'when an application is open' do
      before do
        visit '/'
        click_on 'All open applications'
        click_on('Kit Pound')
      end

      it 'shows the open status badge' do
        badge = page.all('.govuk-tag').last.text

        expect(badge).to match('Open')
      end

      it 'includes the page title' do
        expect(page).to have_content I18n.t('crime_applications.show.page_title')
      end

      it 'includes the applicant details' do
        expect(page).to have_content('AJ123456C')
      end

      it 'includes the date received' do
        expect(page).to have_content('Date received: 24 October 2022')
      end

      context 'when it is not asssigned' do
        it 'shows that the application is unassigned' do
          expect(page).to have_content('Assigned to: Unassigned')
        end

        it 'includes button to assign' do
          expect(page).to have_content(assign_cta)
        end

        it 'does not show the CTAs' do
          expect(page).not_to have_content('Mark as complete')
        end
      end

      context 'when it is asssigned to the current user' do
        before do
          click_on(assign_cta)
        end

        it 'includes the name of the assigned user' do
          expect(page).to have_content('Assigned to: Joe EXAMPLE')
        end

        it 'includes button to unassign' do
          expect(page).to have_content('Remove from your list')
        end

        it 'shows the CTAs' do
          expect(page).to have_content('Mark as complete')
        end
      end

      context 'when it is asssigned to a user who is not the current user' do
        before do
          user = User.create(
            first_name: 'Fred',
            last_name: 'Smitheg',
            auth_oid: '976658f9-f3d5-49ec-b0a9-485ff8b308fa',
            email: 'Fred.Smitheg@justice.gov.uk'
          )

          Assigning::AssignToUser.new(
            user_id: user.id,
            to_whom_id: user.id,
            assignment_id: crime_application_id
          ).call

          click_on 'All open applications'
          click_on('Kit Pound')
        end

        it 'includes the name of the assigned user' do
          expect(page).to have_content('Assigned to: Fred Smitheg')
        end

        it 'includes button to reassign' do
          expect(page).to have_content('Reassign to myself')
        end

        it 'does not shows the CTAs' do
          expect(page).not_to have_content('Mark as complete')
        end
      end
    end
  end

  context 'when an application does not exist in the datastore' do
    before do
      visit '/'
      visit '/applications/123'
    end

    it 'includes the page title' do
      expect(page).to have_content('Page not found')
    end
  end
end
