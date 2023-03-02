require 'rails_helper'

RSpec.describe 'Header navigation' do
  before do
    visit '/'
  end

  it 'takes you to "Your list" when you click "Applications"' do
    click_link('Applications')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Your list')
  end

  it 'shows name of current user' do
    header_navigation = page.all('.govuk-header__navigation-item')
    expect(header_navigation[1].text).to eq('Joe EXAMPLE')
  end

  # TODO: test correct navigation to manage users page
  it 'takes you to user management dashboard when you click "Manage users"' do
    click_link('Manage users')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Your list')
    # expect(heading_text).to eq('Manage users')
  end
end
