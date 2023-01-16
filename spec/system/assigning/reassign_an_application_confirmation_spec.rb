require 'rails_helper'

RSpec.describe 'Reassigning an application confirmation errors' do
  include_context 'with stubbed search'

  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:confirm_path) do
    new_crime_application_reassign_path(crime_application_id)
  end

  let(:assignee) do
    User.create(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: SecureRandom.uuid,
      email: 'Fred.Smitheg@justice.gov.uk'
    )
  end

  before do
    Assigning::AssignToUser.new(
      user_id: assignee.id,
      to_whom_id: assignee.id,
      assignment_id: crime_application_id
    ).call

    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
    click_on('Reassign to myself')
  end

  describe 'reloading the confirm page after a assignment has been unassigned' do
    before do
      CurrentAssignment.delete_all
      visit current_path
    end

    it 'returns not found' do
      expect(page).to have_content(
        'Page not found'
      )
    end
  end

  describe 'when the application is reassigned to another before confirming reassign' do
    let(:another) do
      User.create(
        first_name: 'Fast',
        last_name: 'Janeeg',
        auth_oid: SecureRandom.uuid,
        email: 'Fast.Janeeg@justice.gov.uk'
      )
    end

    let(:reassign_to_another) do
      Assigning::ReassignToUser.new(
        assignment_id: crime_application_id,
        user_id: another.id,
        to_whom_id: another.id,
        from_whom_id: assignee.id
      ).call
    end

    it 'notifies that the assignment had already happened' do
      reassign_to_another

      click_on('Yes, reassign')
      within('.govuk-notification-banner--important') do
        expect(page).to have_content('This application has already been assigned to someone else.')
      end
    end

    it 'redirects to the application details page' do
      reassign_to_another

      expect { click_on('Yes, reassign') }.to change { page.current_path }
        .from(confirm_path).to(
          crime_application_path(crime_application_id)
        )
    end

    it 'does not reassign current user' do
      reassign_to_another

      click_on('Yes, reassign')
      expect(page).to have_content 'Assigned to: Fast Janeeg'
    end
  end

  describe 'when the application is unassigned before confirming reassign' do
    let(:unassign) do
      Assigning::UnassignFromUser.new(
        assignment_id: crime_application_id,
        user_id: assignee.id,
        from_whom_id: assignee.id
      ).call
    end

    it 'notifies that the application was unassigned before they attempted reassignment' do
      unassign

      click_on('Yes, reassign')
      within('.govuk-notification-banner--important') do
        # TODO: Update the error message text
        expect(page).to have_content('This application has already been assigned to someone else.')
      end
    end

    it 'does not reassign' do
      unassign

      click_on('Yes, reassign')
      expect(page).to have_content 'Assigned to: Unassigned'
    end
  end
end
