require 'rails_helper'

RSpec.describe 'Viewing an application that does not exist' do
  before do
    visit '/'
    visit '/applications/123'
  end

  it 'returns page not found' do
    expect(page).to have_content('Page not found')
  end
end
