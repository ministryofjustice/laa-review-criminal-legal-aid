require 'rails_helper'

RSpec.describe 'Header navigation' do
  before do
    visit '/'
  end

  it 'shows name of current user' do
    current_user = page.first('.govuk-header__navigation-item').text
    expect(current_user).to eq('Joe EXAMPLE')
  end

  context 'when user does not have access to manage other users' do
    before do
      visit '/'
    end

    it 'does not have a link to manage users' do
      header = page.first('.govuk-header__navigation-list').text
      expect(header).not_to include('Manage users')
    end
  end

  context 'when user does have access to manage other users' do
    before do
      User.update(current_user_id, can_manage_others: true)
      visit '/'
    end

    it 'takes you to user management dashboard when you click "Manage users"' do
      click_link('Manage users')

      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Manage users')
    end
  end
end
