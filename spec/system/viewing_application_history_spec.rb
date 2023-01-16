require 'rails_helper'

RSpec.describe 'Viewing application history' do
  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
  end

  context 'with a submitted application' do
    before do
      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Thursday 27 Oct 14:09 Provider Name Application submitted')
    end
  end

  context 'with an assigned application' do
    before do
      click_on('Assign to myself')
      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Application assigned to Joe EXAMPLE')
    end
  end

  context 'with an unassigned application' do
    before do
      click_on('Assign to myself')
      first(:button, 'Remove from your list').click
      click_on 'All open applications'
      click_on('Kit Pound')
      click_on('Application history')
    end

    it 'includes the unassignment event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Application removed from Joe EXAMPLE')
    end
  end

  context 'with a reassigned application' do
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
      click_on('Reassign to myself')
      click_on('Yes, reassign')
      click_on('Application history')
    end

    it 'includes the reassignment event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Application reassigned from Fred Smitheg to Joe EXAMPLE')
    end
  end
end
