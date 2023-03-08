require 'rails_helper'

RSpec.describe 'Edit users from manage users dashboard' do
  include_context 'with a logged in admin user'

  before do
    visit '/'
    visit '/admin/manage_users'
    first(:link, 'Edit').click
  end

  it 'loads the correct page' do
    heading = first('h1').text

    expect(heading).to have_content 'Edit a user'
    expect(page).to have_field('can-manage-others-true-field', checked: false)
  end

  it 'allows a users to cancel the editing of a user' do
    click_link 'Cancel'
    heading = first('h1').text
    expect(heading).to have_text('Manage users')
  end

  context 'when update fails' do
    before do
      allow_any_instance_of(User).to receive(:update).and_return(false)
      click_button 'Save'
    end

    it 'rerenders the edit page' do
      heading = first('h1').text

      expect(heading).to have_content 'Edit a user'
    end
  end

  context 'when granting management access' do
    before do
      check 'Give access to manage other users'
      click_button 'Save'
    end

    it 'redirects to the correct page' do
      expect(page).to have_current_path('/admin/manage_users')
    end

    it 'shows correct success flash message' do
      expect(page).to have_content('User has been updated')
    end

    it 'updates can manage others value to Yes' do
      row = find(:xpath, "//table[@class='govuk-table']//tr[contains(td[1], 'joe.example@justice.gov.uk')]")

      expect(row).to have_text('joe.example@justice.gov.uk Yes')
    end
  end

  context 'when revoking management access' do
    before do
      check 'Give access to manage other users'
      click_button 'Save'
      all(:link, 'Edit')[1].click
      uncheck 'Give access to manage other users'
      click_button 'Save'
    end

    it 'redirects to the correct page' do
      expect(page).to have_current_path('/admin/manage_users')
    end

    it 'shows correct success flash message' do
      expect(page).to have_content('User has been updated')
    end

    it 'updates can manage others value to No' do
      row = find(:xpath, "//table[@class='govuk-table']//tr[contains(td[1], 'joe.example@justice.gov.uk')]")

      expect(row).to have_text('joe.example@justice.gov.uk No')
    end
  end
end
