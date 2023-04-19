require 'rails_helper'

RSpec.describe 'Viewing application history' do
  include_context 'with an existing application'
  let(:assign_cta) { 'Assign to your list' }

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
      expect(first_row).to match('Monday 24 Oct 09:50 John Doe Application submitted')
    end
  end

  context 'with an assigned application' do
    before do
      click_on(assign_cta)
      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Application assigned to Joe EXAMPLE')
    end
  end

  context 'with an unassigned application' do
    before do
      click_on(assign_cta)
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
      click_on('Reassign to your list')
      click_on('Yes, reassign')
      click_on('Application history')
    end

    it 'includes the reassignment event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Application reassigned from Fred Smitheg to Joe EXAMPLE')
    end
  end

  context 'with a returned application' do
    let(:return_details) do
      ReturnDetails.new(
        reason: 'evidence_issue',
        details: 'September bank statement required'
      )
    end

    before do
      stub_request(
        :put,
        "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v2/applications/#{crime_application_id}/return"
      ).to_return(body: LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read, status: 200)

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

      Reviewing::SendBack.new(
        user_id: user.id,
        application_id: crime_application_id,
        return_details: return_details.attributes
      ).call

      click_on 'All open applications'
      click_on('Kit Pound')
      click_on('Application history')
    end

    it 'includes the return event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Fred Smitheg Application sent back to provider')
      expect(first_row).to match('Evidence issue')
    end
  end

  context 'with a completed application' do
    before do
      stub_request(
        :put,
        "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v2/applications/#{crime_application_id}/complete"
      ).to_return(body: LaaCrimeSchemas.fixture(1.0).read, status: 200)

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

      Reviewing::Complete.new(
        user_id: user.id,
        application_id: crime_application_id
      ).call

      click_on 'All open applications'
      click_on('Kit Pound')
      click_on('Application history')
    end

    it 'includes the completed event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Fred Smitheg Application complete')
    end
  end
end
