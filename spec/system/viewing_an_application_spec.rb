require 'rails_helper'

RSpec.describe 'Viewing an application' do
  before do
    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.show.page_title')
  end

  it 'includes the users details' do
    expect(page).to have_content('AJ123456C')
  end
end
