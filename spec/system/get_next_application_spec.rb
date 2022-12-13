require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  it 'allows you to get the next application' do
    visit '/'
    click_on 'Get next application'
    expect(page).to have_content('Kit Pound')
    expect(page).to have_content('This application has been assigned to you')
  end

  it 'shows an error when there is no next application' do
    3.times do
      visit '/'
      click_on 'Get next application'
    end

    expect(page).to have_content('Your list')
    expect(page).to have_content('There are no new applications to be reviewed')
  end
end
