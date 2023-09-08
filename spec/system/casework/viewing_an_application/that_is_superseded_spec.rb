require 'rails_helper'

RSpec.describe 'Viewing an application that is superseded' do
  include_context 'with resubmitted application'

  let(:latest_application_url) { "/applications/#{application_id}" }

  before do
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
