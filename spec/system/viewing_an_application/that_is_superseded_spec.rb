require 'rails_helper'

RSpec.describe 'Viewing an application that is superseded' do
  let(:application_id) { '148df27d-4710-4c5b-938c-bb132eb040ca' }
  let(:parent_id) { '5aa4c689-6fb5-47ff-9567-5efe7f8ac211' }
  let(:latest_application_url) { "/applications/#{application_id}" }

  let(:return_details) do
    ReturnDetails.new(
      reason: 'evidence_issue',
      details: 'September bank statement required'
    )
  end

  before do
    Reviewing::ReceiveApplication.call(
      application_id: parent_id,
      submitted_at: '2022-10-24T09:50:04.000+00:00',
      parent_id: nil
    )

    stub_request(
      :put,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{parent_id}/return"
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
      assignment_id: parent_id
    ).call

    Reviewing::SendBack.new(
      user_id: user.id,
      application_id: parent_id,
      return_details: return_details.attributes
    ).call

    Reviewing::ReceiveApplication.call(
      application_id: application_id,
      submitted_at: '2022-10-24T09:50:04.000+00:00',
      parent_id: parent_id
    )

    visit '/'
    visit crime_application_path(parent_id)
  end

  it 'shows the sent back status badge' do
    badge = page.all('.govuk-tag').last.text

    expect(badge).to match('Sent back to provider')
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.show.page_title')
  end

  it 'does not show the copy reference link' do
    expect(page).not_to have_content('Copy reference number')
  end

  it 'shows the resubmitted warning text' do
    expect(page).to have_content('This application has been resubmitted.')
  end

  it 'shows link to the most recent version' do
    expect(page).to have_link('Go to the latest version', href: latest_application_url)
  end

  it 'shows who closed the application' do
    expect(page).to have_content('Closed by: Fred Smitheg')
  end

  it 'does not show button to assign' do
    expect(page).not_to have_content('Assign to your list')
  end

  it 'does not show the CTAs' do
    expect(page).not_to have_content('Mark as completed')
  end
end
