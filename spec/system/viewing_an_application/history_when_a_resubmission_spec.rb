require 'rails_helper'

RSpec.describe "Viewing a resubmitted application's history" do
  let(:parent_id) { '5aa4c689-6fb5-47ff-9567-5efe7f8ac211' }
  let(:application_id) { '148df27d-4710-4c5b-938c-bb132eb040ca' }

  before do
    visit '/'

    travel_to Time.zone.now.yesterday

    user = User.create(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: '976658f9-f3d5-49ec-b0a9-485ff8b308fa',
      email: 'Fred.Smitheg@justice.gov.uk'
    )

    Reviewing::ReceiveApplication.new(
      application_id: parent_id,
      parent_id: nil,
      submitted_at: Time.zone.now.to_s
    ).call

    Assigning::AssignToUser.new(
      user_id: user.id,
      to_whom_id: user.id,
      assignment_id: parent_id
    ).call

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new) {
      instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
    }

    return_details = ReturnDetails.new(
      reason: 'evidence_issue',
      details: 'September bank statement required'
    )

    Reviewing::SendBack.new(
      user_id: user.id,
      application_id: parent_id,
      return_details: return_details.attributes
    ).call

    travel_back

    Reviewing::ReceiveApplication.new(
      application_id: application_id,
      parent_id: parent_id,
      submitted_at: Time.zone.now.to_s
    ).call

    visit history_crime_application_path(application_id)
  end

  it 'includes a link to the previous version of the application in the application history' do
    within('tbody.govuk-table__body') do
      expect { click_on('Go to this version') }.to change { page.current_path }
        .from(history_crime_application_path(application_id))
        .to(crime_application_path(parent_id))
    end
  end

  context 'when viewing the superseded application\'s history' do
    before do
      visit(history_crime_application_path(parent_id))
    end

    it 'shows the resubmission event at the top of the application history' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Application resubmitted Go to this version')
    end

    it 'the resubmission item includes a link to the resubmitted application' do
      expect { click_on('Go to this version') }.to change { page.current_path }
        .from(history_crime_application_path(parent_id))
        .to(crime_application_path(application_id))
    end
  end
end
