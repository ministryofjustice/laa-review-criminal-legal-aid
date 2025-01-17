require 'rails_helper'

RSpec.describe 'Invites from manage users dashboard' do
  include_context 'when logged in user is admin'
  include_context 'with a stubbed mailer'
  let(:notify_mailer_method) { :access_granted_email }

  before do
    visit '/manage-users'
    click_on 'Invite a user'
  end

  it 'loads the correct page' do
    heading = first('h1').text

    expect(heading).to have_content 'Invite a user'
  end

  it 'allows a users to cancel the adding of a new user' do
    click_link 'Cancel'
    heading = first('h1').text
    expect(heading).to have_text('Manage users')
  end

  it 'allows a user with management access to be added' do
    fill_in 'Email', with: 'john@example.com'
    check 'Give access to manage other users'

    click_button 'Invite'

    row = find(:xpath, "//table[@class='govuk-table']//tr[contains(td[1], 'john@example.com')]")

    expect(page).to have_text('john@example.com has been invited')
    expect(row).to have_text('john@example.com Yes')
  end

  it 'notifies the invitee' do
    email = 'jane@example.com'
    fill_in 'Email', with: email

    click_button 'Invite'

    expect(NotifyMailer).to have_received(:access_granted_email).with(email)
    expect(mailer_double).to have_received(:deliver_now)
  end

  it 'allows a user without management access to be added' do
    fill_in 'Email', with: 'jane@example.com'

    click_button 'Invite'

    row = find(:xpath, "//table[@class='govuk-table']//tr[contains(td[1], 'jane@example.com')]")

    expect(page).to have_text('jane@example.com has been invited')
    expect(row).to have_text('jane@example.com No')
  end

  describe 'logging the invitation in the users account history' do
    before do
      email = 'jane@example.com'
      fill_in 'Email', with: email
      click_button 'Invite'
      click_link email
    end

    let(:cells) { page.first('table tbody tr').all('td') }

    it 'describes the event' do
      expect(cells[1]).to have_content 'User invited'
    end

    it 'includes the managers name' do
      expect(cells.last).to have_content 'Joe EXAMPLE'
    end
  end

  describe 'validations' do
    it 'errors when no email is provided' do
      check 'Give access to manage other users'
      click_button 'Invite'

      error_message = first('#user-email-error').text.squish

      expect(error_message).to have_text('Enter an email')
    end

    it 'errors when email is in the wrong format' do
      fill_in 'Email', with: 'WRONG FORMAT'
      check 'Give access to manage other users'
      click_button 'Invite'

      error_message = first('#user-email-error').text.squish

      expect(error_message).to have_text('Invalid email format')
    end

    it 'errors if the user is not unique / already exists' do
      add_two_of_the_same_user
      error_message = first('#user-email-error').text.squish
      expect(error_message).to have_text('User already exists')
    end

    def add_two_of_the_same_user
      fill_in 'Email', with: 'jane@example.com'
      click_button 'Invite'
      click_on 'Invite a user'
      fill_in 'Email', with: 'jane@example.com'
      click_button 'Invite'
    end
  end
end
