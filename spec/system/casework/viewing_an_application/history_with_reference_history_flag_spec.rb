require 'rails_helper'

RSpec.describe 'Viewing application history with reference_history flag enabled' do
  include_context 'with stubbed search'

  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:application_reference) { 555_666_777 }
  let(:assign_cta) { 'Assign to your list' }

  before do
    allow(FeatureFlags).to receive(:reference_history) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }

    # Stub the GetApplication request to ensure it returns the correct reference
    # This overrides the default stub from api_data.rb
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}"
    ).to_return(
      body: JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge('reference' => application_reference).to_json,
      status: 200
    )

    # Create the ApplicationReceived event first so it gets linked to ReferenceHistory stream
    Reviewing::ReceiveApplication.new(
      application_id: crime_application_id,
      parent_id: nil,
      work_stream: 'criminal_applications_team',
      application_type: 'initial',
      submitted_at: Time.zone.parse('2022-10-24T10:50:00.000Z'),
      reference: application_reference
    ).call
  rescue Reviewing::AlreadyReceived
    # Event already exists, ignore
  end

  context 'with a submitted application' do
    before do
      visit open_crime_applications_path
      click_on('Kit Pound')
      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('John Doe Application submitted')
    end
  end

  context 'with an assigned application' do
    before do
      visit open_crime_applications_path
      click_on('Kit Pound')
      click_on(assign_cta)
      click_on('Application history')
    end

    it 'includes the assignment event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Application assigned to Joe EXAMPLE')
    end
  end

  context 'with an unassigned application' do
    before do
      visit open_crime_applications_path
      click_on('Kit Pound')
      click_on(assign_cta)
      first(:button, 'Remove from your list').click
      click_on 'Open applications'
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
        auth_oid: SecureRandom.uuid,
        email: 'Fred.Smitheg@justice.gov.uk'
      )

      Assigning::AssignToUser.new(
        user_id: user.id,
        to_whom_id: user.id,
        assignment_id: crime_application_id,
        reference: application_reference
      ).call

      visit open_crime_applications_path
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
        "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}/return"
      ).to_return(body: LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read, status: 200)

      user = User.create(
        first_name: 'Fred',
        last_name: 'Smitheg',
        auth_oid: SecureRandom.uuid,
        email: 'Fred.Smitheg@justice.gov.uk'
      )

      Assigning::AssignToUser.new(
        user_id: user.id,
        to_whom_id: user.id,
        assignment_id: crime_application_id,
        reference: application_reference
      ).call

      Reviewing::SendBack.new(
        user_id: user.id,
        application_id: crime_application_id,
        return_details: return_details.attributes
      ).call

      visit open_crime_applications_path
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
    include_context 'with a completed application'

    before do
      visit open_crime_applications_path
      click_on('Kit Pound')
      click_on('Application history')
    end

    it 'includes the completed event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Fred Smitheg Application complete')
    end
  end

  context 'with ordinal position for multiple applications' do
    let(:parent_id) { 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa' }
    let(:child_id) { 'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb' }
    let(:unique_reference) { 999_888_777 }

    before do
      # Stub datastore responses for both applications
      parent_data = JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
        'id' => parent_id,
        'parent_id' => nil,
        'reference' => unique_reference,
        'submitted_at' => '2022-10-20T10:00:00.000Z'
      )

      child_data = JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
        'id' => child_id,
        'parent_id' => parent_id,
        'reference' => unique_reference,
        'submitted_at' => '2022-10-27T14:09:11.000Z'
      )

      stub_request(:get, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{parent_id}")
        .to_return(body: parent_data.to_json, status: 200)

      stub_request(:get, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{child_id}")
        .to_return(body: child_data.to_json, status: 200)

      Reviewing::ReceiveApplication.new(
        application_id: parent_id,
        parent_id: nil,
        work_stream: 'criminal_applications_team',
        application_type: 'initial',
        submitted_at: Time.zone.parse('2022-10-20T10:00:00.000Z'),
        reference: unique_reference
      ).call

      Reviewing::ReceiveApplication.new(
        application_id: child_id,
        parent_id: parent_id,
        work_stream: 'criminal_applications_team',
        application_type: 'initial',
        submitted_at: Time.zone.parse('2022-10-27T14:09:11.000Z'),
        reference: unique_reference
      ).call

      visit history_crime_application_path(child_id)
    end

    it 'shows ordinal position in the history for resubmissions' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match(
        'Thursday 27 Oct 2022 3:09pm John Doe Application resubmitted by provider View application 2'
      )
    end
  end

  context 'with an archived application' do
    let(:archived_at) { Time.zone.parse('2023-01-15T14:30:00.000Z') }

    before do
      Deleting::ArchiveApplicationEvent.call(
        id: SecureRandom.uuid,
        data: {
          'id' => crime_application_id,
          'application_type' => 'initial',
          'reference' => application_reference,
          'archived_at' => archived_at.iso8601
        }
      )

      visit history_crime_application_path(crime_application_id)
    end

    it 'includes the archived event in the history' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Sunday 15 Jan 2023 2:30pm Provider Application deleted by provider')
    end

    it 'displays the archived event at the top of the history' do
      rows = page.all('.app-dashboard-table tbody tr')
      expect(rows.first.text).to match('Application deleted by provider')
    end
  end
end
