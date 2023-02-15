require 'rails_helper'

RSpec.describe 'Viewing an application unassigned, open application' do
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    visit '/'
    visit crime_application_path(application_id)
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

  it 'shows that the application is unassigned' do
    expect(page).to have_content('Assigned to: Unassigned')
  end

  it 'includes button to assign' do
    expect(page).to have_content('Assign to myself')
  end

  it 'does not show the CTAs' do
    expect(page).not_to have_content('Mark as complete')
  end
end
