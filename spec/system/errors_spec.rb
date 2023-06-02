require 'rails_helper'

RSpec.describe 'Error pages' do
  it 'shows the generic error page' do
    allow(ApplicationSearchFilter).to receive(:new) {
      raise StandardError
    }

    visit '/'
    click_on 'Search'
    expect(page).to have_content 'Sorry, something went wrong with our service'
  end

  it 'shows application not found error page' do
    visit '/applications/123'
    expect(page).to have_content 'If you’re looking for a specific application, go to all open applications'
  end

  it 'shows not found error page' do
    visit '/foo'
    expect(page).to have_content 'If you copied a web address, please check it’s correct'
  end
end
