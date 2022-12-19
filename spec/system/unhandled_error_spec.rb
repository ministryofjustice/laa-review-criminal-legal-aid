require 'rails_helper'

RSpec.describe 'Unhandled Error' do
  it 'shows the generic error page' do
    allow(ApplicationSearchFilter).to receive(:new) {
      raise SomeCrazyError
    }

    visit '/'
    click_on 'Search'
    expect(page).to have_content 'Sorry, something went wrong with our service'
  end
end
