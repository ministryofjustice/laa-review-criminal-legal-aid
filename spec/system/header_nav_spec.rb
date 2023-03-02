require 'rails_helper'

RSpec.describe 'Header navigation' do
  before do
    visit '/'
  end

  it 'shows name of current user' do
    current_user = page.first('.govuk-header__navigation-item').text
    expect(current_user).to eq('Joe EXAMPLE')
  end

  # TODO: test correct navigation to manage users page
  it 'takes you to user management dashboard when you click "Manage users"' do
    click_link('Manage users')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Your list')
    # expect(heading_text).to eq('Manage users')
  end
end
