require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  it 'allows you to get the next application' do
    visit '/'
    click_on 'Get next application'
    expect(page).to have_content('Kit Pound')
    expect(page).to have_content('This application has been assigned to you')
  end
end
