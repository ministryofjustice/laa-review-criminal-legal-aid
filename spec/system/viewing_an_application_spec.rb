require 'rails_helper'

RSpec.describe 'Viewing an application' do
  include_context 'when applications exist'
  include_context 'when a passported application exist'

  before do
    visit '/applications'
    click_on('Kit Pound')
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.show.page_title')
  end

  it 'includes the users details' do
    expect(page).to have_content('AJ123456C')
  end
end
