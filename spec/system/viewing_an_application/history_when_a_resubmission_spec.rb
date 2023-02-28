require 'rails_helper'

RSpec.describe "Viewing a resubmitted application's history" do
  let(:parent_id) { SecureRandom.uuid }
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    visit '/'

    travel_to Time.zone.now.yesterday

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new) {
      instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
    }

    user = User.create(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: '976658f9-f3d5-49ec-b0a9-485ff8b308fa',
      email: 'Fred.Smitheg@justice.gov.uk'
    )

    Reviewing::ReceiveApplication.new(
      application_id: parent_id,
      submitted_at: Time.zone.now.to_s
    ).call

    Assigning::AssignToUser.new(
      user_id: user.id,
      to_whom_id: user.id,
      assignment_id: parent_id
    ).call

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

  it "includes the previous submission's history" do
    # TODO update to include previous history
    expected_content = "Monday 24 Oct 09:50 John Doe Application submitted"

    within('tbody.govuk-table__body') do
      expect(page).to have_content(expected_content)
    end
  end
end
