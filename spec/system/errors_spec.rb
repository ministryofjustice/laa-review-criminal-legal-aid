require 'rails_helper'

RSpec.describe 'Error pages' do
  it 'shows the generic error page' do
    allow(ApplicationSearchFilter).to receive(:new) {
      raise StandardError
    }

    visit '/'
    click_on 'Search'
    expect(page).to have_content 'Sorry, something went wrong with our service'
    expect(page).to have_css('nav.moj-primary-navigation')
  end

  it 'shows application not found error page' do
    visit '/applications/123'
    expect(page).to have_content "If you're looking for a specific application, go to all open applications."
    expect(page).to have_css('nav.moj-primary-navigation')
  end

  it 'shows not found error page' do
    visit '/foo'
    expect(page).to have_content 'If the web address is correct or you selected a link or button'
    expect(page).to have_css('nav.moj-primary-navigation')
  end

  it 'shows the forbidden page' do
    visit '/forbidden'
    expect(page).to have_content 'Access to this service is restricted'
    expect(page).not_to have_css('nav.moj-primary-navigation')
  end
end
